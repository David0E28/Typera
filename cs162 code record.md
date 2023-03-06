# cs162 code record

## Files and I/O

low level file api

```c
int open(const char* filename, int flags [, mode_t mode])
int creat(const char* filename, mode_t mode)
int close(int filedes)
```

Integer return from open() is a file descripte





```c
//read data from open file usiong file descriptor
//read up to maxsize bytes - might actually read less
ssize_t read(int filedes, void* buffer, size_t maxsize)
ssize_t read(int filedes, const void* buffer, size_t size)
    //example
    main(){
    char buf[1000];
    int fd = open("lowio.c", O_RDONLY, S_IRUSR | S_IWUSR);
    SSIZE_T RD = read(fd, buf, sizeof(buf));
    int err = close(fd);
    ssize_t wr = write(STDOUT_FILENO, buf, rd);
}
```





```c
//operations specific to terminals, devices, networking...

//e.g., ioctl

    //Duplicating  descriptors
    -int dup2(int old, int new);	
    -int dup(int old);
//pipes -channel
//You can write to pip[1] and read from pip[0]
-int pip(int pipfd[2]);

//flie Locking

//memory-mapping files

//Asynchronous I/O
```





```c
//Hight-Level and Low-Level API
//Streams are bufferd in user memory:
printf("beginning of line");
Sleep(10);
printf("end of the line");
//everyting prints out at once witout waiting.they are buffered.
```





```c
//Example
char x = "c";
FILE* f1 = fopen("file.text", "wb");
fwrite("b", sizeof(char), 1, f1);
//fflush(f1);    
FILE* f2 = fopen("file.text", "rb");
fwread(&x, sizeof(char), 1, f2);
//if there is no fflush in the mid,you will never konw if "b" is flushed into the kernal, the result of the programm is uncertain(maybe "c" or "b")
//(user_mode_buffer --> kernal_mode_buffer)
//use kernal_mode_buffer directly is very expensive,use user_buffer if you can!

```



## IPC，PIPES and Sockets 

```c
//review
//return value from fork():pid(like a integer)
//when pid > 0 
	//running in (original) parent process
	//return value is pid of new child
//when pid == 0
	//running in new Child process
//when pid < 0
	//Error! you should write a handle!
	//or it possiblely running in original process
```

WHY FORK??

1. without fork(),you can not create new process.(mostly)

	   

pipe for communication(one way)

```c
//allocates two file descriptors in the process
int pipe(int fileds[2]);

//after the last "write" descriptor is closed, pipe is effectively closed:Reads return "EOF".

//after the last "read" descriptor is closed,writes generate SIGPIPE signals,and if process ignores that, write will fails with an "EPIPE" error!
   
```

Sockets for two-way communication between processes on same or different machine

1. two queues(one in each direction)

how do we name the objects we are opening?how to address them

​	by Namespace 

1. ​		IP  address
2. ​        Port Number

## Synchronization and Mutual Exclusion

```c
//Conceptually, the scheduling loop of the operating system looks like:
Loop{
    RunThread();
    ChooseNextThread();
    SaveStateOfCPU(curTCB);
    LoadStateOfCPU(newTCB);
}
//this is a infinite loop in the OS once OS is working
```

- how do i run a thread?

1. Load its state(register  PC SP) into CPU
2. Load environment(virtual memory space,etc)
3. Jump to the PC



<img src="https://i.328888.xyz/2023/03/06/dliVZ.png" alt="dliVZ.png" border="0" />



- How does the dispatcher get control back?

	1. internal events:thread returns control voluntarily

		- Blocking I/O(implicitly)

		- Waiting on a singal from other thread

		- Thread executes a  **yield()**

			```c
			computePI() {
				while(1) {
				    ComputeNextDigit();
			        yield();
				}
			}//run forever
			```

		```c
		//context switch
		Switch(tCur, tNew) {
		    /*unload old thread*/
		    TCB[tCur].regs.r7 = CPU.r7;
		    	......
		    TCB[tCur].regs.r0 = CPU.r0;
		    TCB[tCur].regs.sp = CPU.sp;
		    TCB[tCur].regs.retpc = CPU.retpc;//return addr
		    
			/*Load and execute new thread*/
			CPU.r7 = TCB[tNew].regs.r7;
		    	......
			CPU.retpc = TCB[tNew].regs.retpc
			reburn;//return to CPU.retpc
		}
		
		
		```

		TCB + Stack(user/kearnal)contains complete restartable state of Thread !

		

	2.  External events:thread get preempted 

	

	

	Process VS. Thread 

	overhead--开销

	one CPU core

	<img src="https://i.328888.xyz/2023/03/06/dly1Q.png" alt="dly1Q.png" border="0" />

 	  multiple CPU core

​		  <img src="https://i.328888.xyz/2023/03/06/dlACE.png" alt="dlACE.png" />



what happend when theard blocks on I/O?

- trap to OS

 use the timer interrupt to force scheduling decisions

- ```c
	TimerInterrupt() {
	    DoPeriodicHouseKeeping();
	    run _new_thread();
	
	```

	How do we initialize TCB and Stack?

	- Stacke pointer made to point at stack.

	- Pc return address-->Os(asm)routine ThreadRoot()

	- Two arg Register(a0 and a1)iniialized to fcnpter and fcnArgPtr. 

		

		Initialize stack data?

		- important part is in the register
		- stack frame as just before body of  ThreadRoot() really get started.

		

		what happends if a thread oges int oa inifinite loop?

		​	it is going to weaste its own CPU time and other threads is fine, and there may a thread goes in and kill the unnormal thread.

		

		Fix bank problem with Locks!

		

		<img src="https://i.328888.xyz/2023/03/06/dwWPU.png" alt="dwWPU.png" border="0" />

		

		

		

		Thread competition game

		```c
		//Thread A
		i = 0;
		while(i < 10) 
		    i = i + 1;
		printf("A wins!")
		  -------------------------------- 
		//THread B
		i = 0;
		while(i > -10) 
		    i = i - 1;//same as i++;
		printf("B wins!")
		```

		​    it may no winner forever......Thread A and B overwriting element **i** forever and it never go below -10 or go beyond 10

		

		



