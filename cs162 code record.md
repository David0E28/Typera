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



​	Loccks provide two atomic operations:

​			--**acquire(&mylock)**-wait until lock is free, then mark it as busy(or to say calling thread **holds** the lock after it returns)

​			--**release(mylock)**-mark lock as free (can only be called by a thread that holding the lock, after it returns ,  the calling thread on longer holds the lock)



Usage:



 

```c
mutex buf_lock = <initially unlocked>
Producer(item) {
    acquire(&buf_lock)
    while(buffer full) {}; // Wait for a freeslot
    enqueue(item);
    release(&buf_lock);
}

Consumer() {
  acquire(&buf_lock);
  while (buffer empty) {};
  item = dequeue(); //Wait for arrival
  release(&buf_lock);
  return item;
  }//worest code,while buffer empty or full,the lock is dead
```





<img src="https://i.328888.xyz/2023/03/06/hAfwq.png" alt="hAfwq.png" border="0" />

it works on both singal core and mutiple cores ,but the code is doing release and acquire the lock for most of the time ,it's what we called **Busy Waiting** mode,which will waste a lot of CPU cycles...not good anyway.  



​	Usage

- Mutual Exclusion(initial value = 1)(binary Semaphore)
- Scheduling Constraints(initial value = 0)

## Synchronization 2 : Semaphores  Lock Implementation  Atomic Instructions

​	recall

```c
process A() {
    B() 
  }

process B() {
    while (TRUE) {
        yield();//thread B give up cpu 
      }
  }
```



<img src="https://i.328888.xyz/2023/03/08/SHQXF.png" alt="SHQXF.png" border="0" />



Hardware context switch supported in x86



Semaphores 

1.  kind of generalized lock
2.  Definition : a Semaphore has a non-negative integer value and supports the following two operate 
	- Down() or P()   //proberen
	- Up() or V()       //verhogen

and only those two operations,and they are atomic

Correctness Constraints

Only one thread can manipulate buffer queue at a time(mutual exclusion)(互斥)

```c
//buying milk problem
if(nomilk) {
	if(noNote) {
        //if Thread checked and switched here...
		leave Note;//lock
		buy milk;
		remove note; //unlock
	}
}
//still too much milk but only occasionally---Thread can get context switched after checking milk and note but before buying milk!!
```

how to improve???

```c
//Thread A                                //Thread B
leave note A;						leave note B;
while (Note B) {					if(noNote A) {
    								 if (no milk){
                                         	buy milk;
                                        }
                                      }
                                      remove note B;
    do nothing;
}
if (noMilk) {
    buy milk;
}
remove note A;
//it works!
//but it is a little complicated,and while A is doing nothing(waiting),it is consuming CPU time
```

with lock ,its going to be really easy...

```c
acquire(&milklock);
if (noMilk)  buy milk;
realease (&milklock);
//other thread wait if locked,sleep if wait too long

```

The different between busy-waiting and semaphore-down is:

- busy-waiting consuming CPU time
- semaphore-down puts thread to sleeping list

**ALL Synchronization involves waiting**

​		 

When to enable interrupt in Lock

```c
Acquire() {
disable interrupts;
    if(value == busy) {
        put on a wait queue;
        Go to Sleep();
        //<------------enable here!
    } else {
        value = BUSY;
    }
    enable interrupts;
}
//but which thread enable inerrupts after go to sleep???

```

- responsibility of the next thread to re-enable interrupts
- when the sleeping thread wakes up, returns  to acquire and re-enable interrupts.
- 我们无需在 Go to sleep（）处主动enable interrupts，因为另一个thread会enable interrupts after current thread goes to sleep.(关中断禁止了抢占，但是没有禁止当前任务进行主动调度)



<img src="https://i.328888.xyz/2023/03/09/SpbJq.png" alt="SpbJq.png" border="0" />



B put itself to sleep by calling a system call, system call in kernel put B into sleep, but it is B who called system call...

keep doing system call is going to make everything slow...how can we make it better

## Synchronization 3: Atomic Instructions Monitors  Readers/Writers

Alternative: atomic instruction sequences

​		These instructions read a value and write a new value atomically

​		**Hardware** is responsible for implementing this correctly

Using Compare&Swap without lock 

```c
compare&swap (&address, reg1, reg2) {
	if (reg1 == M[address] {  //if there is no conflict
        M[address] = rsg2;
        return success;
    }else {
        return false;
	 }
}
 //if thousands of threads doing same thing simultaneously 
addToQueue(&object) 
do {			    	//repeat until no conflict
    load r1<--M(root)   //get ptr to current head
    set  r1-->M[object] //Save link in new object
   } until (compare&swap (&root, r1, object))//atomic without lock   ,faster
        
```

​		

 

