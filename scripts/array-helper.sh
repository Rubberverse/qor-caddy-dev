#!/bin/bash
printf "[array-helper] Pre-eliminary checking of environmental variables - Pass 1/2\n"

if ! [ "${CADDY_MODULES}" = "" ]; then
    printf "[array-helper - Check 1] PASSED\n"
else
    printf "[array-helper - Check #1] FAILED: Empty value supplied for CADDY_MODULES\n"
    printf "[array-helper - Check #1] FAILED: If this is intentional, pass 0 to CADDY_MODULES environmental variable to build Caddy without modules\n"
    exit 2
fi

if ! [ "${CADDY_TAG_VERSION}" = "" ] ; then
    printf "[array-helper - Check #2] PASSED]\n"
else
    printf "[array-helper - Check #2] FAILED: Empty value supplied for CADDY_TAG_VERSION\n"
    printf "[array-helper - Check #2] WARNING: Build process will fallback to master branch which may not build successfully\n"
    export CADDY_TAG_VERSION=master
fi

printf "[array-helper - init] Initializing variables\n"
FILE_PATH=/app/caddy/main.go
TEMP_FILE=/app/caddy/temp.go
PROCESSED=false

printf "[array-helper - init] Creating necessary files\n"
touch /app/caddy/temp.go

printf "[array-helper - init] Parsing CADDY_MODULES into Array\n"
read -a CADDY_MODULES_ARRAY <<< "$CADDY_MODULES"

printf "[array-helper - debug] Listing variables and file directories\n"
printf "%b" "FILE_PATH: ${FILE_PATH}\n"
printf "%b" "TEMP_FILE: ${TEMP_FILE}\n"
printf "%b" "ARRAY PROCESSED: ${PROCESSED}\n"
ls -l /app/caddy

printf "[array-helper - init] Sanity check\n"
echo -n "" > $TEMP_FILE

printf "[array-helper] Adding modules to /app/caddy/main.go\n"

while IFS= read -r line
do
    if [[ $line == *"// plug in extra Caddy modules here"* ]] && [ "$PROCESSED" = false ]; then
        for module in "${CADDY_MODULES_ARRAY[@]}"
            do
                echo "\t_ \"$module\"" >> $TEMP_FILE
        done        
	PROCESSED=true
    fi

    printf "[array-helper] Writing module \"$module\" to file\n"
    echo "$line" >> $TEMP_FILE 
done < "$FILE_PATH"

printf "[array-helper] Overwriting main.go with temporary file\n"
mv $TEMP_FILE $FILE_PATH

printf "[array-helper - debug] Show go module"
cat $FILE_PATH
cat $TEMP_PATH

# https://unix.stackexchange.com/a/403401
# https://stackoverflow.com/a/30212526
# v1.0.3 - now passes shellcheck