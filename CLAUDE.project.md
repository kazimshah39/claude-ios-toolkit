## Multi-Agent Build Error Policy

Multiple agents work on this project simultaneously. When handling Xcode build errors:

- **Only fix errors in files you created or modified this session.**
- **Ignore errors in all other files** — another agent owns them.
- If a foreign error blocks your compilation, report it and stop. Do not attempt a fix or workaround.
