/****This program uses map of CUDA
 to convert color image to grayscale image*****/

#include <cuda_runtime.h>
#include <device_laumch_parameters.h>
#include <stdio.h>

__global__ void color2gray(int width,int height,int *picr_d,int *picg_d,int *picb_d,int *picGray_d)
{
	int i=blockIdx.x*blockDim.x+threadIdx.x;
	if(i<width*height)
		picGray_d[i]=(int)(picr_d[i] * 0.299 + picg_d[i] * 0.587 + 0.114 * picb_d[i]);
}

int main(int argc, char *argv[])
{
	int width;
	int height;
	FILE *f;
	int *picr_h; //red channel host
	int *picb_h; //blue channel host
	int *picg_h; //green channel host
	
	int *picr_d; //red channel device
	int *picb_d; //blue channel device
	int *picg_d; //green channel device
	int *picGray_d; //grayscale image device
	int i,j;
	char *str;
	
	
	width=atoi(argv[1]);
	height=atoi(argv[2]);
	
	picr_h=(int*)malloc(sizeof(int)*width*height);	
	
	picb_h=(int*)malloc(sizeof(int)*width*height);	
		
	picg_h=(int*)malloc(sizeof(int)*width*height);
	
	str=(char*)malloc(sizeof(char)*width);
	
	cudaMalloc(&picGray_d,sizeof(int)*width*height);
	cudaMalloc(&picr_d,sizeof(int)*width*height);
	cudaMalloc(&picb_d,sizeof(int)*width*height);
	cudaMalloc(&picg_d,sizeof(int)*width*height);
	
	//reading a ppm file
	f=fopen(argv[3],"r");
	fgets(str,width,f);
	fgets(str,width,f);
	fgets(str,width,f);
	for(i=0;i<height;i++){
		fgets(str,width,f);
		for(j=0;j<width;j++){
			sscanf(str,"%d",&picr_h[j+i*height]);
			sscanf(str,"%d",&picg_h[j+i*height]);
			sscanf(str,"%d",&picb_h[j+i*height]);
		}
	}
	fclose(f);
		
	
	cudaMemcpy(picr_d, picr_h, width*height*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(picb_d, picb_h, width*height*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(picg_d, picg_h, width*height*sizeof(int), cudaMemcpyHostToDevice);
	
	
	
	//color2gray kernel launch
	color2gray<<<height,width>>>(width,height,picr_d,picg_d,picb_d,picGray_d);
	
	cudaMemcpy(picr_h, picGray_d, width*height*sizeof(int), cudaMemcpyDeviceToHost);
	
	f=fopen(argv[4],"w");
	fprintf(f,"P3\n%d %d\n255\n",width,height);
	for(i=0;i<height;i++){
		for(j=0;j<width;j++){
			fprintf(f,"%d %d %d ",picr_h[j+i*height],picr_h[j+i*height],picr_h[j+i*height]);
		}
		fprintf(f,"\n");
	}
	
	fclose(f);
	
	cudaFree(picr_d);
	cudaFree(picg_d);
	cudaFree(picb_d);
	cudaFree(picGray_d);
	
	free(picr_h);
	free(picg_h);
	free(picb_h);
	
}
	
	
	
	
