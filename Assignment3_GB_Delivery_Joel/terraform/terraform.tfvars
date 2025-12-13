# 1. SSH Key Configuration (CRITICAL)
# Point this to where your public key actually exists on your machine.
# On Linux/Mac it is usually ~/.ssh/id_rsa.pub
# On Windows it might be C:/Users/YourName/.ssh/id_rsa.pub
ssh_key_path = "~/.ssh/id_rsa.pub"

# 2. Region Configuration
# You can change these if you want different regions
location_main = "spaincentral"
blue_region   = "spaincentral"
green_region  = "francecentral"

# 3. Traffic Weights (Blue/Green Split)
# Change these values to shift traffic. Total should ideally equal 100.
blue_weight   = 10
green_weight  = 90