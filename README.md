![GitHub](https://img.shields.io/github/license/ryderstorm/pocket_article_exporter?style=for-the-badge)
![GitHub Workflow Status (with branch)](https://img.shields.io/github/actions/workflow/status/ryderstorm/pocket_article_exporter/rspec.yml?branch=main&label=Tests&style=for-the-badge)
![GitHub Workflow Status (with branch)](https://img.shields.io/github/actions/workflow/status/ryderstorm/pocket_article_exporter/build.yml?branch=main&style=for-the-badge)
![GitHub last commit (branch)](https://img.shields.io/github/last-commit/ryderstorm/pocket_article_exporter/main?style=for-the-badge)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ryderstorm/pocket_article_exporter?style=for-the-badge)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/ryderstorm/pocket_article_exporter?style=for-the-badge)
![GitHub repo file count](https://img.shields.io/github/directory-file-count/ryderstorm/pocket_article_exporter?style=for-the-badge)

## What is this?

TBD

## Pre-requisites

The app uses the following environment variables:

| Variable Name         | Description                                                                                                                                                                                                                                                   |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `POCKET_CONSUMER_KEY` | _Required_. Your Pocket API consumer key. Instructions on setting one up can be found [here](https://getpocket.com/developer/docs/authentication).                                                                                                            |
| `POCKET_REDIRECT_URI` | _Optional_. The URL that the Pocket API should redirect to during the authorization flow. If you can host the app with a publicly available URL (maybe through ngrok), set this to that URL. If not, you can leave this blank and manually authorize the app. |

## Running the app locally

### Via Docker

```bash
 docker run --rm --name pocket_article_exporter -e POCKET_CONSUMER_KEY -e POCKET_REDIRECT_URI -p 8999:8999 ghcr.io/ryderstorm/pocket_article_exporter:main
```

### Locally via Ruby

```bash
bundle install
./bin/start.sh
```

Once you have the app up and running, visit http://localhost:8999 and you should see the main page of the app:

![Start page](./public/app_sceenshot_start_page.png)

To see more logging for debugging, run the app with the `LOG_LEVEL` environment variable set to `DEBUG`.

## References

- https://getpocket.com/developer/docs/getstarted/web
- https://getpocket.com/developer/docs/authentication

```

```
