#export PATH := /usr/local/cuda/bin:$(PATH)
CXX = nvcc

#NVFLAGS=-Wno-deprecated-declarations -gencode arch=compute_89,code=compute_89

NAME = main

$(NAME): $(NAME).cu
	$(CXX) $(NVFLAGS) $< -o $@

.PHONY: clean

clean:
	rm -f $(NAME)

.PHONY: run

run: $(NAME)
	./$<
