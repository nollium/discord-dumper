#!/bin/bash

API.get() {
	ROUTE="$1"
	TOKEN="$2"
	curl -s "https://discord.com/api/v9/$ROUTE" \
		-H 'authority: discord.com' \
		-H 'accept: */*' \
		-H 'accept-language: fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7' \
		-H "authorization: $TOKEN" \
		-H 'cache-control: no-cache' \
		-H 'cookie: _ga=GA1.2.852698825.1611054843; __dcfduid=0fc619403f8b9f5981fa0c9d26ea14c0; __sdcfduid=f1a1ab70f62111ebbcc91d6d5bb9f5f7ab96737e3c9a0aea1d8c90a8a2675448788be5723df08053f31d98f6c48896f3; OptanonConsent=isIABGlobal=false&datestamp=Fri+May+27+2022+17%3A04%3A27+GMT%2B0200+(heure+d%E2%80%99%C3%A9t%C3%A9+d%E2%80%99Europe+centrale)&version=6.33.0&hosts=; __stripe_mid=fc52549f-afbf-4ba3-a6fb-d76ccfef42db4984f7; __cfruid=7ab0464af6c7a0c3875a62a6b753d9c3bfdcf153-1666044863; __cf_bm=HqsebhIgStwV.Fufayii6G2NbBzXkHnyN0KueWtICl8-1666052426-0-ATfgKgZrM83OV2GxFZOb1+MjqfyLHVAjW9qxBDZiMeBvSXyHCmvw6l8i5qSJ0bpv26RScqjncHhHyDRMr4RA2bTTieH/a7oZkORWVCX86hEVqSno8md0UiTL+KleM3303g==' \
		-H 'dnt: 1' \
		-H 'pragma: no-cache' \
		-H 'sec-ch-ua: "Chromium";v="106", "Google Chrome";v="106", "Not;A=Brand";v="99"' \
		-H 'sec-ch-ua-mobile: ?0' \
		-H 'sec-ch-ua-platform: "Windows"' \
		-H 'sec-fetch-dest: empty' \
		-H 'sec-fetch-mode: cors' \
		-H 'sec-fetch-site: same-origin' \
		-H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36' \
		-H 'x-discord-locale: fr' \
		-H 'x-super-properties: eyJvcyI6IldpbmRvd3MiLCJicm93c2VyIjoiQ2hyb21lIiwiZGV2aWNlIjoiIiwiYnJvd3Nlcl91c2VyX2FnZW50IjoiTW96aWxsYS81LjAgKFdpbmRvd3MgTlQgMTAuMDsgV2luNjQ7IHg2NCkgQXBwbGVXZWJLaXQvNTM3LjM2IChLSFRNTCwgbGlrZSBHZWNrbykgQ2hyb21lLzEwNi4wLjAuMCBTYWZhcmkvNTM3LjM2IiwiYnJvd3Nlcl92ZXJzaW9uIjoiMTA2LjAuMC4wIiwib3NfdmVyc2lvbiI6IjEwIiwicmVmZXJyZXIiOiIiLCJyZWZlcnJpbmdfZG9tYWluIjoiIiwicmVmZXJyZXJfY3VycmVudCI6IiIsInJlZmVycmluZ19kb21haW5fY3VycmVudCI6IiIsInJlbGVhc2VfY2hhbm5lbCI6InN0YWJsZSIsImNsaWVudF9idWlsZF9udW1iZXIiOjE1MjUzMiwiY2xpZW50X2V2ZW50X3NvdXJjZSI6bnVsbH0=' \
		--compressed
}

dump_channel() {
	CHANNEL_ID="$1"
	TOKEN="$2"
	DATA=$(API.get "channels/$CHANNEL_ID" "$TOKEN")

	FILE=$(jq -r '"#" + .name + ".json" ' <<< "$DATA")

	echo "$DATA"

	echo "[">"$FILE"
	DATA=$(API.get "channels/$CHANNEL_ID/messages?limit=100" "$TOKEN")
	ID=$(jq -r 'last | .id' <<< "$DATA")
	while true; do
		
		echo "$ID"
		echo "$DATA" >> "$FILE"

		DATA=$(API.get "channels/$CHANNEL_ID/messages?before=$ID&limit=100" "$TOKEN")

		ID=$(jq -r 'last | .id' <<< "$DATA")

		if [ "$?" != 0 ];then
			break;
		fi

		echo "," >> "$FILE"

	done

	echo "]" >> "$FILE"

	TMP_FILE="/tmp/$(date +%s).$FILE"
	jq -r 'flatten | reverse'  "$FILE" > "$TMP_FILE"
	cat "$TMP_FILE" > "$FILE"
}

dump_guild() {
	# ID_LIST="$1"
	GUILD_ID="$1"
	TOKEN="$2"

	DATA=$(API.get "guilds/$GUILD_ID" "$TOKEN")
	
	NAME=$(jq -r '.name' <<< "$DATA")
	
	FILENAME="$NAME.json"
	mkdir -p "$NAME"
	cd "$NAME"

	echo "$DATA" > "$FILENAME"

	DATA=$(API.get "guilds/$GUILD_ID/channels" "$TOKEN")

	CHANNEL_ID_LIST=$(jq -r '.[] | .id' <<< "$DATA")

	for CHANNEL_ID in $CHANNEL_ID_LIST;do
		dump_channel "$CHANNEL_ID" "$TOKEN"
	done

	cd -
}

GUILD_ID="$1"
TOKEN="$(cat secret.txt)"

dump_guild "$GUILD_ID" "$TOKEN"
