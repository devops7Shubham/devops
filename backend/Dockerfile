# Use an official Golang image as the base image
FROM golang:1.19

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy the Go Modules manifests
COPY go.mod go.sum ./

# Download the Go Modules dependencies
RUN go mod tidy

# Copy the entire backend code into the container
COPY . .

# Build the Go app
#RUN go mod tidy && go mod vendor

RUN go build -o main .

# Expose port 8080
EXPOSE 8080

# Command to run the executable
CMD ["./main"]
