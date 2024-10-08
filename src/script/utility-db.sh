#!/bin/bash
##
# Color  Variables
##
RESTORE=$(echo -en '\001\033[0m\002')
RED=$(echo -en '\001\033[00;31m\002')
GREEN=$(echo -en '\001\033[00;32m\002')
YELLOW=$(echo -en '\001\033[00;33m\002')
BLUE=$(echo -en '\001\033[00;34m\002')
MAGENTA=$(echo -en '\001\033[00;35m\002')
PURPLE=$(echo -en '\001\033[00;35m\002')
CYAN=$(echo -en '\001\033[00;36m\002')
LIGHTGRAY=$(echo -en '\001\033[00;37m\002')
LRED=$(echo -en '\001\033[01;31m\002')
LGREEN=$(echo -en '\001\033[01;32m\002')
LYELLOW=$(echo -en '\001\033[01;33m\002')
LBLUE=$(echo -en '\001\033[01;34m\002')
LMAGENTA=$(echo -en '\001\033[01;35m\002')
LPURPLE=$(echo -en '\001\033[01;35m\002')
LCYAN=$(echo -en '\001\033[01;36m\002')
WHITE=$(echo -en '\001\033[01;37m\002')

##
# BASH menu script that database setup:
#   - Backup Database
#   - Restore Database
#   - Truncate Database
##
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USERNAME=root
DB_PASSWORD=$MYSQL_ROOT_PASSWORD
DB_NAME=$MYSQL_DATABASE

credentialsFile=/tmp/mysql-credentials.cnf
if [ ! -f "$credentialsFile" ]; then
    touch "$credentialsFile"
    {
        echo "[client]"
        echo "user=$DB_USERNAME"
        echo "password=$DB_PASSWORD"
        echo "host=$DB_HOST"
        echo "port=$DB_PORT"
        # echo "ssl-mode=DISABLED"
    } >>$credentialsFile
fi

function show_databases() {
    echo ""
    echo "${LCYAN}Show databases on ${DB_HOST}:${DB_PORT}:${RESTORE} "
    i=1
    for DB in $(mysql --defaults-extra-file="$credentialsFile" -N -B -e "SHOW DATABASES"); do
        num=$((i++))
        echo "Database ${GREEN}$num${RESTORE}: ${YELLOW}$DB${RESTORE}"
    done
    echo "${GREEN}Show databases successfully${RESTORE}"
    echo ""
}
function backup_database() {
    echo ""
    echo "${LCYAN}Backup database on ${DB_HOST}:${DB_PORT}:${RESTORE} "
    read -r -p "Database name: " DB_NAME
    if [ ! -d "/tmp/backup" ]; then
        mkdir /tmp/backup
    fi
    echo "${LMAGENTA}Backup database...${RESTORE}"
    mysqldump --defaults-extra-file="$credentialsFile" \
        --max-allowed-packet=1024M --single-transaction --lock-tables --set-gtid-purged=OFF --no-data \
        "${T}" | gzip -c >"/tmp/backup/${DB_NAME}-${T}.sql.gz"
    echo "${GREEN}Database $DB_NAME backup created successfully${RESTORE}"
    echo ""
}
function restore_database() {
    echo ""
    echo "${LCYAN}Restore database on ${DB_HOST}:${DB_PORT}:${RESTORE} "
    echo "${LMAGENTA}Restore database...${RESTORE}"
    i=1
    for T in $(mysql --defaults-extra-file="$credentialsFile" -N -B -e "SHOW TABLES FROM $DB_NAME"); do
        num=$((i++))
        echo "Restore data table ${GREEN}$num${RESTORE}: ${YELLOW}$DB_NAME.$T${RESTORE}"
        mysql --defaults-extra-file="$credentialsFile" \
            --max_allowed_packet=1024M --default-character-set=utf8 --binary-mode=1 \
            "${DB_NAME}" <"/tmp/backup/${DB_NAME}-tables/${T}.sql"
    done
    echo "${GREEN}Database ${DB_NAME} restored successfully${RESTORE}"
    echo ""
}
function trucate_database() {
    echo ""
    echo "${LCYAN}Cleaning database on ${DB_HOST}:${DB_PORT}:${RESTORE} "
    echo "${LMAGENTA}Truncate database...${RESTORE}"
    i=1
    for T in $(mysql --defaults-extra-file="$credentialsFile" -N -B -e "SHOW TABLES FROM $DB_NAME"); do
        num=$((i++))
        echo "Truncate data table ${GREEN}$num${RESTORE}: ${YELLOW}$DB_NAME.$T${RESTORE}"
        mysql --defaults-extra-file="$credentialsFile" -N -B -e "SET FOREIGN_KEY_CHECKS = 0; TRUNCATE TABLE $DB_NAME.$T; SET FOREIGN_KEY_CHECKS = 1;"
    done
    echo "${GREEN}Truncate database ${DB_NAME} successfully${RESTORE}"
    echo ""
}

# Function to display menu
menu() {
    echo -ne "
Actions menu for setup database:
${GREEN}1)${RESTORE} Show Databases
${GREEN}2)${RESTORE} Backup Database
${GREEN}3)${RESTORE} Restore Database
${GREEN}4)${RESTORE} Truncate Database
${GREEN}0)${RESTORE} Exit
${BLUE}Choose an option:${RESTORE} "
    read -r a
    case $a in
    1)
        show_databases
        menu
        ;;
    2)
        backup_database
        menu
        ;;
    3)
        restore_database
        menu
        ;;
    4)
        trucate_database
        menu
        ;;
    0) exit 0 ;;
    *)
        echo -e "${RED}Wrong option.${RESTORE}"
        menu
        ;;
    esac
}

# Call the menu function
menu
