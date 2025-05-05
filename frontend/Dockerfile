# Use an official Node.js image as a base
FROM node:14.17.0-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy the rest of the frontend code
COPY . .

# Build the React app for production
RUN npm run build

# Expose port 3000 (default for React)
EXPOSE 3000

# Command to run the React app
CMD ["npm", "start"]
