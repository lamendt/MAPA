import os
with open("buffer.hex", "w") as f_out:
    for x in range (256):
        for y in range (240):
            color_int = (x + y) % 256
            hex_str = f"{color_int:02X}\n"
            f_out.write(hex_str)