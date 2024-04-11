if __name__ == "__main__":
    c_lines = open("c.out").readlines()

    header_len = 9
    for c_line in c_lines[9:]:
        if "The" in c_line:
            header_len = 8

    c_lines = c_lines[header_len:]

    f_lines = open("f.out").readlines()

    split_point = None
    for i in range(len(c_lines)):
        if "The" in c_lines[i]:
            c_lines[i] = c_lines[i].split("The")[0] + c_lines[i+1]
            
            split_point = i

    if split_point:
        c_lines = c_lines[:split_point+1] + c_lines[split_point+2:]

    test_pass = True

    for i in range(len(c_lines)):
        value_c = round(float(c_lines[i]), 8)
        value_f = round(float(f_lines[i]), 8)

        if value_c != value_f:
            print(f">>> {value_c}")
            print(f"--- {value_f}")

            test_pass = False
    if test_pass:
        print("PASS!")
    else:
        print("FAIL :(")
