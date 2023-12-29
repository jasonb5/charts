import sys
import argparse
import requests

parser = argparse.ArgumentParser()

parser.add_argument("url", help="URL to check")
parser.add_argument("--success", nargs="+", type=int, required=True)
parser.add_argument("--skip-verify", action="store_true")

args = vars(parser.parse_args())

print(args)

try:
    response = requests.get(args["url"], verify=not args["skip_verify"])
except Exception:
    sys.exit(1)

for status_code in args["success"]:
    if response.status_code == status_code:
        print(f"Match status code {response.status_code} to {status_code}")

        sys.exit(0)

print(f"Failed to match any status code {args['success']}")

sys.exit(1)
