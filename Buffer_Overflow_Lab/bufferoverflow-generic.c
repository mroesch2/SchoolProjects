#include <stdio.h>
#include <string.h>

void secretFunction()
{
    printf("Congratulations!\n");
    printf("You have entered in the secret function! \n");
}

void FileCompress()
{
   	char buffer[20];
	char exists[28] = "test -f ";
	char zip[25] = "gzip ";
	char cp[45] = "cp ";
	char mv[45] = "mv ";
	int status;
	
   	printf("Enter file name to compress:\n");
   	fgets(buffer);
	
//Chaged to strncpy because it is sfaaaaaaer and requires the size of the buffer
	strncpy(exists, buffer, sizeof(buffer));
	status = system(exists);
	if (status == 256) {
		printf("%s", "File not found, exiting");
		return;
	}

	strncpy(cp, buffer, sizeof(buffer));
	strcat(cp, " ");
	strncpy(cp, buffer, sizeof(buffer);
	strcat(cp, "1");
	system(cp);


	strnpy(zip, buffer, sizeof(buffer));
	status = system(zip);
	if (status == 256) {
		printf("%s", "Gzip failed, exiting");
		return;
	}
	else {
		printf("%s has been zipped. \n", buffer);
	}

	strncpy(mv, buffer, sizeof(buffer));
	strcat(mv, "1");
	strcat(mv, " ");
	strncpy(mv, buffer, sizeof(buffer));
	system(mv);

	return;
}	

int main()
{
    FileCompress();
    return 0;
}

// $ python -c 'print "a"*NN + "\xDD\xCC\xBB\xAA"' | ./bufferoverflow
// Find correct values of NN, AA, BB, CC, DD so that the python call from above 
// overwrites the return register in stack memory and jumps to the secretFunction 
// Hint: use objdump utility to find correct values AA, BB, CC, DD
