import os

def split_json_file(input_file, output_dir, max_file_size_mb=200):
    # Convert MB to bytes
    max_file_size_bytes = max_file_size_mb * 1024 * 1024
    file_count = 0
    current_file_size = 0

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    output_file = open(os.path.join(output_dir, f'yelp_academic_dataset_user_{file_count}.json'), 'w', encoding='utf-8')

    with open(input_file, 'r', encoding='utf-8') as infile:
        for line in infile:
            line_size = len(line.encode('utf-8'))

            if current_file_size + line_size > max_file_size_bytes:
                output_file.close()  # Close the current output file
                file_count += 1
                current_file_size = 0
                output_file = open(os.path.join(output_dir, f'yelp_academic_dataset_user_{file_count}.json'), 'w', encoding='utf-8')

            # Write the line to the output file
            output_file.write(line)
            current_file_size += line_size

    output_file.close()  # Close the last output file

# Example usage
input_file = 'DATA/SPLIT/yelp_academic_dataset_user.json'
output_dir = 'DATA/SPLIT'
split_json_file(input_file, output_dir, max_file_size_mb=200)
