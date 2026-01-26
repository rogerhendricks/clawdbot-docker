#!/bin/bash
node /home/clawdbot/auto-approve.js &
exec clawdbot gateway --allow-unconfigured --bind lan
