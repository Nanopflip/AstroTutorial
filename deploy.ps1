$remote = "wunderland\administrator@192.168.2.2"
$remoteDir = "C:\inetpub\wwwroot"
$localDir = "./dist"

# Clear remote directory h
ssh $remote "rm -rf ${remoteDir}/*"

# Copy local directory
scp -r "$localDir/*" "${remote}:$remoteDir/"
