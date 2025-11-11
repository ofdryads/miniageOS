
echo "[+] Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "[+] Setting up & installing Docker..."
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# get docker GPG key + add repository, then install docker
sudo mkdir -p /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli

# Allow this user to run docker if not sudo
sudo usermod -aG docker "$USER"
newgrp docker

cd ~/miniageos/docker || exit 1

chmod +x build-docker-image.sh
chmod +x run-docker.sh

echo "[+] Building Docker image..."
./build-docker-image.sh

echo "[+] Running the Docker container and building the system image ..."
./run-docker.sh