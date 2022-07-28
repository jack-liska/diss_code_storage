delete(instrfind);
config = 'BaudRate=115200 DTR=1 RTS=1 ReceiveTimeout=1';
oldverbo = IOPort('Verbosity',0);
[handle, errmsg] = IOPort('OpenSerialPort', '/dev/ttyACM0', config);
IOPort('Read', handle)