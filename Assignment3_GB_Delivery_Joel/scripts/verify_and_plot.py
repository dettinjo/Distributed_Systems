import os
import subprocess
import time
import requests
import matplotlib.pyplot as plt
from collections import Counter

# --- CONFIGURATION ---
REQUEST_COUNT = 100  # High sample size for accuracy
DELAY = 0.5          # Slight delay to respect DNS TTL
TF_DIR_REL = "../terraform"
TF_DIR_LOCAL = "./terraform"

def get_tf_dir():
    """Locates the Terraform directory."""
    if os.path.exists(TF_DIR_REL):
        return TF_DIR_REL
    elif os.path.exists(TF_DIR_LOCAL):
        return TF_DIR_LOCAL
    else:
        raise FileNotFoundError("Could not locate Terraform directory.")

def get_terraform_output(output_name):
    """Fetches a specific output variable from Terraform."""
    try:
        tf_dir = get_tf_dir()
        val = subprocess.check_output(
            ["terraform", "output", "-raw", output_name], 
            cwd=tf_dir
        ).decode("utf-8").strip()
        return val
    except Exception as e:
        print(f"[!] Error fetching '{output_name}' from Terraform: {e}")
        return "0"

def resolve_and_check(domain):
    """Resolves DNS manually and checks content."""
    try:
        # Resolve IP using system 'dig' to bypass python caching
        result = subprocess.check_output(["dig", "+short", domain]).decode("utf-8").split('\n')
        # Filter out CNAMEs, get the last IP
        ips = [line for line in result if line and not line.endswith('.')]
        if not ips: return "Error"
        resolved_ip = ips[0]

        # Request specific IP with Host header
        response = requests.get(f"http://{resolved_ip}", headers={"Host": domain}, timeout=2)
        content = response.text

        if "Spain" in content or "Blue" in content:
            return "Blue (Spain)"
        elif "France" in content or "Green" in content:
            return "Green (France)"
        else:
            return "Unknown"
    except Exception:
        return "Error"

def generate_chart(counts, total, target_blue, target_green):
    """Generates a pie chart and saves it with weights in the filename."""
    labels = list(counts.keys())
    sizes = list(counts.values())
    colors = ['#5DBCD2' if 'Blue' in label else '#98FB98' for label in labels]

    plt.figure(figsize=(9, 7))
    
    # Create Pie Chart
    plt.pie(sizes, labels=labels, colors=colors, autopct='%1.1f%%', startangle=140, shadow=True)
    
    # Dynamic Title
    plt.title(
        f"Traffic Distribution (N={total})\n"
        f"Target Configuration: Blue {target_blue}% / Green {target_green}%", 
        fontsize=14, fontweight='bold'
    )
    plt.axis('equal') 
    
    # --- DYNAMIC FILENAME ---
    filename = f"traffic_distribution_{target_blue}Blue_{target_green}Green.png"
    output_path = f"../screenshot/{filename}"
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    plt.savefig(output_path)
    print(f"\n[✔] Diagram saved to: {output_path}")

def main():
    print(f"--- Azure Traffic Manager Verification (N={REQUEST_COUNT}) ---")
    
    # 1. Get Config from Terraform
    domain_raw = get_terraform_output("traffic_manager_dns")
    domain = domain_raw.replace("http://", "").replace("https://", "")
    
    target_blue = get_terraform_output("blue_weight")
    target_green = get_terraform_output("green_weight")
    
    print(f"[*] Target Domain: {domain}")
    print(f"[*] Configured Weights -> Blue: {target_blue}% | Green: {target_green}%")
    print("[*] Starting sampling...\n")

    results = []
    
    try:
        for i in range(1, REQUEST_COUNT + 1):
            region = resolve_and_check(domain)
            results.append(region)
            
            blue_c = results.count("Blue (Spain)")
            green_c = results.count("Green (France)")
            print(f"\r[{i}/{REQUEST_COUNT}] Blue: {blue_c} | Green: {green_c} | Last: {region}      ", end="", flush=True)
            time.sleep(DELAY)
            
    except KeyboardInterrupt:
        print("\n[!] Stopped by user.")

    print("\n\n--- Final Results ---")
    counts = Counter(results)
    for env, count in counts.items():
        print(f"{env}: {count} ({count/len(results)*100:.1f}%)")

    # 2. Generate Diagram with Targets
    try:
        generate_chart(counts, len(results), target_blue, target_green)
    except ImportError:
        print("[!] Matplotlib not found. Skipped diagram generation.")

if __name__ == "__main__":
    main()