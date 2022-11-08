# discord-dumper
Bash scripts to dump all messages in a discord server/guild.

## Requirements:

    curl
    jq
    bash

## Usage:
- Provide your authorization token in `secret.txt`
`echo "<token>" > secret.txt`

![image](https://user-images.githubusercontent.com/54525684/200690802-01e20a57-f2ad-4d0a-8393-0af7a52c9a33.png)


- Launch `get.sh` with the guild ID:
`bash get.sh "<guild ID>"`

- The dump json files are located in `./<guild-name>/*.json`
- You can use the `read.sh` script to display the files conveniently.
`bash read.sh "<json file>"`
