#!/bin/bash
set -e

wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" > /etc/apt/sources.list.d/mongodb-org-4.4.list
apt-get update
apt-get install -y mongodb-org unzip
systemctl enable --now mongod
sleep 5

mongo <<EOF
use admin
db.createUser({user:"backup", pwd:"${backup_password}", roles:["root"]})
db.createUser({user:"tasky", pwd:"${tasky_password}", roles:[{role:"readWrite", db:"go-mongodb"}]})
EOF

sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
printf "security:\n  authorization: enabled\n" >> /etc/mongod.conf
systemctl restart mongod

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip
./aws/install

echo '${backup_password}' > /root/.mongo-backup-pw
chmod 600 /root/.mongo-backup-pw

cat > /usr/local/bin/mongo-backup.sh <<'SCRIPT'
#!/bin/bash
TS=$(date +%F-%H%M)
PW=$(cat /root/.mongo-backup-pw)
mongodump --username backup --password "$PW" --authenticationDatabase admin --db go-mongodb --archive=/tmp/db-$TS.gz --gzip
aws s3 cp /tmp/db-$TS.gz s3://${bucket_name}/db-$TS.gz
rm /tmp/db-$TS.gz
SCRIPT
chmod +x /usr/local/bin/mongo-backup.sh
echo "0 2 * * * root PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin /usr/local/bin/mongo-backup.sh" > /etc/cron.d/mongo-backup
/usr/local/bin/mongo-backup.sh
