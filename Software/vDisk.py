__author__ = 'skar.Wei'


import serial
import threading
import struct
import time
import os


IDLE = 0
READ = 1
WRITE = 2
READ_ADDR = 3
WRITE_ADDR = 4
READ_DATA = 5
WRITE_DATA = 6
BLOCKSIZE = 512
f = open('../../../PentiumX/Software/VirtualDisk.vhd', 'rb+')
# Diskdata = f.read()


class Disk(threading.Thread):
    def __init__(self, ser):
        super(Disk, self).__init__()
        self.running = False
        self.ser = ser
        self.state = IDLE

    def run(self):
        self.running = True
        while self.running:
            if self.state == IDLE:
                data = self.ser.read(1)
                if data == b'!':
                    self.state = READ
                elif data == b'*':
                    self.state = WRITE
                else:
                    self.state = IDLE
            elif self.state == READ:
                block = 0
                count = 0
                while True:
                    data = self.ser.read(1)
                    if data == b'#':
                        break
                    else:
                        digit = struct.unpack('B', data)[0]
                        print("r digit as: " + digit.__str__())
                        block += digit << count
                        count += 8
                print('read block number: ')
                print(block)
                print(hex(block * BLOCKSIZE))
                # section = Diskdata[block * BLOCKSIZE: block * BLOCKSIZE + BLOCKSIZE]
                f.seek(block * BLOCKSIZE)
                section = f.read(BLOCKSIZE)
                print [hex(ord(i)) for i in section]
                print "len: " + len(section).__str__()
                # print(int(section))
                time.sleep(0.2)
                self.ser.write(section)
                self.state = IDLE
            elif self.state == WRITE:
                block = 0
                count = 0
                while True:
                    data = self.ser.read(1)
                    if data == b'#':
                        break
                    else:
                        # count += 1
                        digit = struct.unpack('B', data)[0]
                        print("w digit as: " + digit.__str__())
                        block += digit << count
                        count += 8
                print('write blck number: ')
                print(block)
                data = self.ser.read(512)
                f.seek(block * BLOCKSIZE)
                f.write(data)
                # for i in range(0, 512, 1):
                #     Diskdata[block * BLOCKSIZE + i] = data[i]
                #     Diskdata.
                # Diskdata
                # Diskdata[block * BLOCKSIZE + i] = data[i]
                print [hex(ord(i)) for i in data]
                print len(data)
                # print(struct.unpack('B', data))
                self.state = IDLE
    def stop(self):
        self.running = False
        print("Disk stoppd")


ser = serial.Serial(3)
# 115200
ser.setBaudrate(115200)
# EIGHT
ser.setByteSize(serial.Serial.BYTESIZES[3])
#
ser.setStopbits(serial.Serial.STOPBITS[0])
# none
ser.setParity(serial.Serial.PARITIES[0])

disk = Disk(ser)

disk.start()

x = raw_input("press\n")

disk.stop()
os._exit(0)
disk.join()

f.close()


