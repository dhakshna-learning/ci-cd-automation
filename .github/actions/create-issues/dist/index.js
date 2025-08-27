const fs = require('fs');
const yaml = require('js-yaml');
const github = require('@actions/github');
const core = require('@actions/core');

async function run() {
  try {
    const templatePath = core.getInput('template_path');
    const file = fs.readFileSync(templatePath, 'utf8');

    // Separate front matter (between ---) and body
    const match = file.match(/^---\n([\s\S]*?)\n---\n([\s\S]*)$/);
    if (!match) {
      throw new Error('Invalid template format');
    }
    const frontMatterRaw = match[1];
    const body = match[2];

    const frontMatter = yaml.load(frontMatterRaw);

    const token = process.env.GITHUB_TOKEN;
    const octokit = github.getOctokit(token);

    // Replace placeholders like {{ env.ENVIRONMENT }} and {{ payload.sender.login }}
    // For demo, just use environment variables and GitHub context

    const env = process.env;
    const githubContext = github.context;

    let title = frontMatter.title.replace(/{{\s*env\.ENVIRONMENT\s*}}/g, env.ENVIRONMENT || '');
    let labels = frontMatter.labels ? frontMatter.labels.split(',').map(l => l.trim()) : [];

    let issueBody = body
      .replace(/{{\s*payload\.sender\.login\s*}}/g, githubContext.actor)
      .replace(/{{\s*env\.RUNNUMBER\s*}}/g, env.RUNNUMBER || '')
      .replace(/{{\s*env\.ENVIRONMENT\s*}}/g, env.ENVIRONMENT || '');

    const response = await octokit.rest.issues.create({
      owner: githubContext.repo.owner,
      repo: githubContext.repo.repo,
      title,
      body: issueBody,
      labels,
    });

    core.info(`Created issue #${response.data.number}`);
  } catch (error) {
    core.setFailed(error.message);
  }
}

run();
