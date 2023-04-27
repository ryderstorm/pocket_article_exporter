![GitHub](https://img.shields.io/github/license/ryderstorm/pocket_article_exporter?style=for-the-badge)
![GitHub Workflow Status (with branch)](https://img.shields.io/github/actions/workflow/status/ryderstorm/pocket_article_exporter/rspec.yml?branch=main&label=Tests&style=for-the-badge)
![GitHub Workflow Status (with branch)](https://img.shields.io/github/actions/workflow/status/ryderstorm/pocket_article_exporter/build.yml?branch=main&style=for-the-badge)
![GitHub last commit (branch)](https://img.shields.io/github/last-commit/ryderstorm/pocket_article_exporter/main?style=for-the-badge)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ryderstorm/pocket_article_exporter?style=for-the-badge)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/ryderstorm/pocket_article_exporter?style=for-the-badge)
![GitHub repo file count](https://img.shields.io/github/directory-file-count/ryderstorm/pocket_article_exporter?style=for-the-badge)

## What is this?

TBD

## Prerequisites

You must have the following environment variables set:

| Variable Name         | Description                                                                                                                                                                                                 |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `POCKET_CONSUMER_KEY` | Your Pocket API consumer key. Instructions on setting one up can be found [here](https://getpocket.com/developer/docs/authentication).                                                                      |
| `POCKET_REDIRECT_URI` | The redirect URI you set up for your Pocket API consumer key. This must be a valid URI. It doesn't have to be a real URI, but it must be a valid URI. I used `http://localhost:8999` for local development. |

## Running the app locally

### Via Docker

```bash
 docker run --rm --name pocket_article_exporter -e POCKET_CONSUMER_KEY -e POCKET_REDIRECT_URI -p 8999:8999 ghcr.io/ryderstorm/pocket_article_exporter:main
```

Then visit http://localhost:8999 or whatever you set your `POCKET_REDIRECT_URI` to.

---

## References

- https://getpocket.com/developer/docs/getstarted/web
- https://getpocket.com/developer/docs/authentication
