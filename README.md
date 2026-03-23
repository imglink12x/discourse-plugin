# ImgLink Plugin for Discourse

Official ImgLink integration for Discourse with reliable media uploads, scoped API key support, retry handling, and admin diagnostics.

## Summary

This plugin connects Discourse to ImgLink so communities can upload images from posting workflows and insert direct/viewer links safely and consistently.

## Features

- Upload images from Discourse posting workflows
- Return direct CDN links and viewer links
- Scoped API key authentication (security-first)
- Retry + idempotency behavior for unstable networks
- Admin diagnostics for auth/upload/delete validation
- Structured logging for easier troubleshooting

## Compatibility

- Discourse 2.8+ (update if your support range differs)
- Self-hosted Discourse deployments

## Repository

https://github.com/imglink12x/discourse-plugin

## Installation

1. SSH into your Discourse host.
2. Add the plugin to `containers/app.yml` under `hooks > after_code`:

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/imglink12x/discourse-plugin.git
```

3. Rebuild Discourse:

```bash
./launcher rebuild app
```

4. Open Discourse Admin and configure plugin settings.

## Configuration

Navigate to:

**Admin → Settings → Plugins → ImgLink**

### Required setup

1. Create an ImgLink API key in your ImgLink account.
2. Use minimum required scopes:
   - `upload:create`
   - `image:delete` (optional; only if delete workflows are enabled)
3. Set your API key in `imglink_api_key`.
4. Save settings and run diagnostics.

## Settings

| Name | Description |
|---|---|
| `imglink_api_key` | ImgLink API key for authenticated upload requests |
| `imglink_api_endpoint` | ImgLink API base URL (default: `https://imglink.cc/api/v1`) |
| `imglink_max_retries` | Maximum retry attempts for failed uploads |
| `imglink_retry_delay_ms` | Delay between retries (milliseconds) |
| `imglink_timeout_ms` | Request timeout per upload (milliseconds) |
| `imglink_enable_diagnostics` | Enables admin-side diagnostics tools |
| `imglink_log_level` | Plugin logging verbosity |

## Security

- Use scoped API keys only
- Rotate keys regularly
- Never commit API keys to source control
- Restrict plugin settings to trusted admins

## Troubleshooting

- Verify API key validity and scopes
- Confirm API endpoint reachability from the Discourse server
- Run plugin diagnostics from admin settings
- Check Discourse logs for auth/upload errors

## Contributing

Issues and pull requests are welcome.

When opening an issue, include:
- Discourse version
- Plugin version/commit
- Reproduction steps
- Relevant logs/error output

## License

MIT

## Support

- Docs: https://imglink.cc/tools/forum-plugins
- Issues: https://github.com/imglink12x/discourse-plugin/issues
