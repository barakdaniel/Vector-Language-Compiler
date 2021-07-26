#include <stdio.h>
#include <stdlib.h>

void vectorGetScalar(int* arr, int size, int val) {
	for(int i=0; i<size; i++) {
		arr[i] = val;
	}
}

void vectorGetVector(int* arr, int size, int* arr2) {
	for(int i=0; i<size; i++) {
		arr[i] = arr2[i];
	}
}

int* vectorsIndexing(int* arr, int size, int* arr2) {
	int* tmp = malloc(sizeof(int)*size);
	for(int i=0; i<size; i++) {
		tmp[i] = arr[arr2[i]];
	}
	return tmp;
}

int* vectorOpScalar(int* arr, int size, int scl, char op) {
	int* tmp = malloc(sizeof(int)*size);
	if(op == '+') { for(int i=0; i<size; i++) tmp[i] = arr[i] + scl; }
	else if(op == '-') { for(int i=0; i<size; i++) tmp[i] = arr[i] - scl; }
	else if(op == '*') { for(int i=0; i<size; i++) tmp[i] = arr[i] * scl; }
	else if(op == '/') { for(int i=0; i<size; i++) tmp[i] = arr[i] / scl; }
	return tmp;
}

int* vectorOpVector(int* arr, int size, int* arr2, char op) {
	int* tmp = malloc(sizeof(int)*size);
	if(op == '+') { for(int i=0; i<size; i++) tmp[i] = arr[i] + arr2[i]; }
	else if(op == '-') { for(int i=0; i<size; i++) tmp[i] = arr[i] - arr2[i]; }
	else if(op == '*') { for(int i=0; i<size; i++) tmp[i] = arr[i] * arr2[i]; }
	else if(op == '/') { for(int i=0; i<size; i++) tmp[i] = arr[i] / arr2[i]; }
	return tmp;
}

int vectorDotVector(int* arr, int size, int* arr2) {
	int sum = 0;
	for(int i=0; i<size; i++) { sum += arr[i] * arr2[i]; }
	return sum;
}

void printVec(int* arr, int size) {
	printf("[");
	for(int i=0; i<size-1; i++) {
		printf("%d, ", arr[i]);
	}
	printf("%d", arr[size-1]);
	printf("]\n");
}

int main(void) {

	int* tmp;
	int iter_idx=0;

/* Start of your source code translation */
	int x;
	int y;
	int i;
	int v1[6];
	int v2[6];
	int v3[6];
	x=2;
	vectorGetScalar(v1, 6, 2*x);
	printVec(v1, 6);
	int tmp_vec0[] = {1,1,2,2,3,3};
	vectorGetVector(v2, 6, tmp_vec0);
	printf("%d\n", 	vectorDotVector(v1, 6, v2));
	y=v2[4];
	printf("%d\n", y);
	i=0;
	for(iter_idx=0; iter_idx<y; iter_idx++) {
	v1[i]=i;
	i=i+1;
	}
	int* tmp_vec1 = vectorsIndexing(v2,6,v1);
	printVec(tmp_vec1, 6);
	int tmp_vec2[] = {5,4,3,2,1,0};
	int* tmp_vec3 = vectorsIndexing(v1,6,tmp_vec2);
	int* tmp_vec4 = vectorsIndexing(v2,6,tmp_vec3);
	printVec(tmp_vec4, 6);
	int* tmp_vec5 = vectorOpVector(v1, 6, v2, '+');
	vectorGetVector(v3, 6, tmp_vec5);
	printVec(v3, 6);
	int tmp_vec6[] = {2,1,0,2,2,0};
	printf("%d\n", v2[(	vectorDotVector(tmp_vec6, 6, v3)/10)]);
	int a[3];
	int tmp_vec7[] = {10,0,20};
	vectorGetVector(a, 3, tmp_vec7);
	i=0;
	for(iter_idx=0; iter_idx<3; iter_idx++) {
	int tmp_vec8[] = {1,0,0};
	if(	vectorDotVector(a, 3, tmp_vec8)) {
	printf("%d\n", i);
	printVec(a, 3);
	int tmp_vec9[] = {2,0,1};
	int* tmp_vec10 = vectorsIndexing(a,3,tmp_vec9);
	vectorGetVector(a, 3, tmp_vec10);
	}
	i=i+1;
	}
	int z[4];
	vectorGetScalar(z, 4, 10);
	int tmp_vec11[] = {2,4,6,8};
	int* tmp_vec12 = vectorOpVector(z, 4, tmp_vec11, '+');
	int* tmp_vec13 = vectorOpScalar(tmp_vec12, 4, 2, '/');
	vectorGetVector(z, 4, tmp_vec13);
	int* tmp_vec14 = vectorOpScalar(z, 4, 3, '-');
	int tmp_vec15[] = {2,3,4,5};
	int* tmp_vec16 = vectorOpVector(tmp_vec14, 4, tmp_vec15, '+');
	vectorGetVector(z, 4, tmp_vec16);
	printVec(z, 4);
	int tmp_vec17[] = {1,1,1,1};
	printf("%d\n", 	vectorDotVector(z, 4, tmp_vec17));
/* End of your source code translation */

	return 0;
}