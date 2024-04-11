if __name__ == "__main__":
    c_lines = open("c.out").readlines()[9:]
    f_lines = open("f.out").readlines()

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
