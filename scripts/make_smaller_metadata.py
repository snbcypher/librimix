import argparse
import os
import pandas as pd

# Command line arguments
parser = argparse.ArgumentParser()
parser.add_argument('--orig_metadata_dir', type=str, required=True,
                    help='Path to original metadata files')
parser.add_argument('--new_metadata_dir', type=str, required=True,
                    help='Path to directory to save new metadata files')
parser.add_argument('--percent', type=float, required=True,
                    help='Amount of mixes to keep')


def main(args):
    orig_metadata_dir = args.orig_metadata_dir
    new_metadata_dir = args.new_metadata_dir
    os.makedirs(new_metadata_dir, exist_ok=True)
    percent = args.percent
    assert 0 <= percent and percent <= 1
    
    os.makedirs(new_metadata_dir, exist_ok=True)
    for folder in os.listdir(orig_metadata_dir):
        for file_name in os.listdir(os.path.join(orig_metadata_dir, folder)):
            if 'info' in file_name:
                df = pd.read_csv(os.path.join(orig_metadata_dir, folder, file_name))
                df.to_csv(os.path.join(new_metadata_dir, folder, file_name), index=False)
            else:
                df = pd.read_csv(os.path.join(orig_metadata_dir, folder, file_name))
                last_line = int(df.shape[0] * percent)
                df = df.head(last_line)
                os.makedirs(os.path.join(new_metadata_dir, folder), exist_ok=True)
                df.to_csv(os.path.join(new_metadata_dir, folder, file_name), index=False)
    
if __name__ == "__main__":
    args = parser.parse_args()
    main(args)

