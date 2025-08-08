# 🏦 Spring Boot Banking Application

![Java](https://img.shields.io/badge/Java-17-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.3.3-brightgreen)
![MySQL](https://img.shields.io/badge/MySQL-8.0-blue)
![Maven](https://img.shields.io/badge/Maven-3.8+-red)
![Docker](https://img.shields.io/badge/Docker-Enabled-blue)

A comprehensive, secure banking web application built with Spring Boot, featuring modern web technologies and enterprise-grade security. This application provides essential banking operations with a user-friendly interface and robust backend architecture.

## 🎯 Purpose & Overview

The Spring Boot Banking Application is designed to simulate real-world banking operations with a focus on:
- **Security**: Spring Security integration with authentication and authorization
- **Scalability**: Cloud-native architecture with container support
- **Modern UI**: Thymeleaf templating with responsive design
- **Data Persistence**: JPA/Hibernate with MySQL database
- **DevOps Ready**: Docker containerization and CI/CD pipeline support

## ✨ Key Features

### 🔐 Security Features
- **Spring Security Integration**: Role-based access control (RBAC)
- **Authentication & Authorization**: Secure login/logout functionality
- **Session Management**: Secure session handling
- **CSRF Protection**: Cross-site request forgery protection
- **Password Security**: Encrypted password storage

### 💳 Banking Operations
- **Account Management**: Create, view, and manage bank accounts
- **Transaction Processing**: Secure money transfers and payments
- **Transaction History**: Detailed transaction logs and history
- **Balance Tracking**: Real-time account balance updates
- **Multi-Account Support**: Support for multiple account types

### 🌐 Web Interface
- **Responsive Design**: Mobile-friendly user interface
- **Thymeleaf Templates**: Server-side rendering for optimal SEO
- **Bootstrap Integration**: Modern, professional styling
- **Real-time Updates**: Dynamic content updates
- **Intuitive Navigation**: User-friendly interface design

### 🔧 Technical Features
- **RESTful APIs**: Well-designed REST endpoints
- **Database Integration**: MySQL with JPA/Hibernate
- **Connection Pooling**: Optimized database connections
- **Error Handling**: Comprehensive error handling and logging
- **Configuration Management**: Externalized configuration

## 📋 Prerequisites

### Required Software
- **Java Development Kit (JDK)**: Version 17 or higher
- **Apache Maven**: Version 3.8.0 or higher
- **MySQL Database**: Version 8.0 or higher
- **Docker**: Version 20.10+ (for containerization)
- **Git**: Latest version for version control

### Development Tools (Recommended)
- **IDE**: IntelliJ IDEA Ultimate, Eclipse IDE, or Visual Studio Code
- **MySQL Workbench**: For database management
- **Postman**: For API testing
- **Docker Desktop**: For container management

### System Requirements
- **RAM**: Minimum 4GB, Recommended 8GB+
- **Storage**: At least 2GB free space
- **OS**: Windows 10+, macOS 10.14+, or Linux (Ubuntu 18.04+)

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
# Clone the repository
git clone <repository-url>
cd Springboot-BankApp

# Verify repository structure
ls -la
```

### 2. Database Setup
```bash
# Start MySQL service
sudo systemctl start mysql

# Login to MySQL
mysql -u root -p

# Create database
CREATE DATABASE bankappdb;
CREATE USER 'bankapp_user'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON bankappdb.* TO 'bankapp_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 3. Configure Application Properties
```bash
# Edit application properties
nano src/main/resources/application.properties

# Update database configuration
spring.datasource.url=jdbc:mysql://localhost:3306/bankappdb?useSSL=false&serverTimezone=UTC
spring.datasource.username=bankapp_user
spring.datasource.password=your_secure_password
```

### 4. Build the Application
```bash
# Clean and compile
mvn clean compile

# Run tests
mvn test

# Package application
mvn clean package

# Skip tests during packaging (if needed)
mvn clean package -DskipTests
```

### 5. Run the Application

#### Method 1: Using Maven
```bash
# Run with Maven
mvn spring-boot:run

# Run with specific profile
mvn spring-boot:run -Dspring-boot.run.profiles=dev
```

#### Method 2: Using JAR file
```bash
# Run the packaged JAR
java -jar target/bankapp-0.0.1-SNAPSHOT.jar

# Run with custom configuration
java -jar target/bankapp-0.0.1-SNAPSHOT.jar --spring.profiles.active=prod
```

#### Method 3: Using Docker
```bash
# Build Docker image
docker build -t bankapp:latest .

# Run container
docker run -p 8080:8080 --name bankapp-container bankapp:latest

# Run with environment variables
docker run -p 8080:8080 \
  -e SPRING_DATASOURCE_URL=jdbc:mysql://host.docker.internal:3306/bankappdb \
  -e SPRING_DATASOURCE_USERNAME=bankapp_user \
  -e SPRING_DATASOURCE_PASSWORD=your_secure_password \
  --name bankapp-container \
  bankapp:latest
```

## 🛠️ Development Commands

### Maven Commands
```bash
# Compile source code
mvn compile

# Run tests
mvn test

# Run specific test class
mvn test -Dtest=BankappApplicationTests

# Package application
mvn package

# Clean build artifacts
mvn clean

# Install to local repository
mvn install

# Run application
mvn spring-boot:run

# Generate project reports
mvn site

# Check for dependency updates
mvn versions:display-dependency-updates
```

### Docker Commands
```bash
# Build image
docker build -t bankapp:v1.0 .

# Run container
docker run -d -p 8080:8080 --name bankapp bankapp:v1.0

# View logs
docker logs bankapp

# Execute commands in container
docker exec -it bankapp /bin/bash

# Stop container
docker stop bankapp

# Remove container
docker rm bankapp

# View container stats
docker stats bankapp
```

### Database Commands
```bash
# Connect to MySQL
mysql -u bankapp_user -p bankappdb

# Backup database
mysqldump -u bankapp_user -p bankappdb > bankapp_backup.sql

# Restore database
mysql -u bankapp_user -p bankappdb < bankapp_backup.sql

# View tables
SHOW TABLES;

# Describe table structure
DESCRIBE accounts;
DESCRIBE transactions;
```

## 🧪 Testing

### Running Tests
```bash
# Run all tests
mvn test

# Run tests with coverage
mvn test jacoco:report

# Run integration tests only
mvn failsafe:integration-test

# Run specific test method
mvn test -Dtest=AccountServiceTest#testCreateAccount

# Run tests in parallel
mvn test -T 4

# Generate test report
mvn surefire-report:report
```

### Test Categories
- **Unit Tests**: Test individual components in isolation
- **Integration Tests**: Test component interactions
- **Repository Tests**: Test data layer functionality
- **Controller Tests**: Test web layer endpoints
- **Security Tests**: Test authentication and authorization

### Test Coverage
```bash
# Generate coverage report
mvn clean test jacoco:report

# View coverage report
open target/site/jacoco/index.html
```

## ⚙️ Configuration

### Application Profiles
The application supports multiple profiles for different environments:

#### Development Profile (application-dev.properties)
```properties
# Development database
spring.datasource.url=jdbc:mysql://localhost:3306/bankappdb_dev
spring.jpa.show-sql=true
logging.level.com.example.bankapp=DEBUG
```

#### Production Profile (application-prod.properties)
```properties
# Production database
spring.datasource.url=${DATABASE_URL}
spring.jpa.show-sql=false
logging.level.root=WARN
server.port=${PORT:8080}
```

#### Test Profile (application-test.properties)
```properties
# In-memory H2 database for testing
spring.datasource.url=jdbc:h2:mem:testdb
spring.jpa.hibernate.ddl-auto=create-drop
```

### Environment Variables
```bash
# Database Configuration
export SPRING_DATASOURCE_URL="jdbc:mysql://localhost:3306/bankappdb"
export SPRING_DATASOURCE_USERNAME="bankapp_user"
export SPRING_DATASOURCE_PASSWORD="your_secure_password"

# Application Configuration
export SPRING_PROFILES_ACTIVE="prod"
export SERVER_PORT="8080"
export LOGGING_LEVEL_ROOT="INFO"

# Security Configuration
export SPRING_SECURITY_USER_NAME="admin"
export SPRING_SECURITY_USER_PASSWORD="admin_password"
```

### Custom Configuration Properties
```properties
# Application specific configuration
app.name=Banking Application
app.version=1.0.0
app.description=Secure Banking Web Application

# Security settings
app.security.jwt.secret=${JWT_SECRET:mySecretKey}
app.security.jwt.expiration=${JWT_EXPIRATION:86400}

# File upload settings
app.upload.max-file-size=10MB
app.upload.max-request-size=10MB

# Email configuration
app.email.enabled=${EMAIL_ENABLED:false}
app.email.smtp.host=${EMAIL_HOST:localhost}
app.email.smtp.port=${EMAIL_PORT:587}
```

## 🔧 Development Guidelines

### Code Style
- Follow Java naming conventions
- Use meaningful variable and method names
- Keep methods small and focused (max 20 lines)
- Write comprehensive JavaDoc comments
- Use proper exception handling

### Architecture Patterns
- **MVC Pattern**: Separation of concerns
- **Repository Pattern**: Data access abstraction
- **Service Layer**: Business logic encapsulation
- **DTO Pattern**: Data transfer objects for API responses

### Best Practices
- **Dependency Injection**: Use Spring's IoC container
- **Transaction Management**: Proper transaction boundaries
- **Validation**: Input validation at controller level
- **Logging**: Use SLF4J with Logback
- **Testing**: Maintain 80%+ test coverage

## 📚 API Documentation

### Authentication Endpoints
```
POST /login - User login
POST /logout - User logout
GET /register - Registration form
POST /register - User registration
```

### Account Management
```
GET /accounts - List user accounts
GET /accounts/{id} - Get account details
POST /accounts - Create new account
PUT /accounts/{id} - Update account
DELETE /accounts/{id} - Delete account
```

### Transaction Operations
```
GET /transactions - List transactions
GET /transactions/{id} - Get transaction details
POST /transactions/transfer - Money transfer
POST /transactions/deposit - Deposit money
POST /transactions/withdraw - Withdraw money
```

### Health & Monitoring
```
GET /actuator/health - Application health
GET /actuator/info - Application information
GET /actuator/metrics - Application metrics
```

## 🐳 Docker Configuration

### Dockerfile Optimization
The application uses a multi-stage build for optimization:
- **Stage 1**: Maven build with full JDK
- **Stage 2**: Runtime with minimal JRE
- **Result**: Smaller image size and faster deployment

### Docker Compose Setup
```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Rebuild and restart
docker-compose up --build -d
```

## 🚀 Deployment

### Local Deployment
```bash
# Build and run locally
mvn clean package
java -jar target/bankapp-0.0.1-SNAPSHOT.jar
```

### Cloud Deployment
- **AWS**: Deploy to EC2, ECS, or Elastic Beanstalk
- **Azure**: Deploy to Azure App Service or AKS
- **Google Cloud**: Deploy to Google App Engine or GKE
- **Heroku**: Direct git-based deployment

### Kubernetes Deployment
- Pod specifications with resource limits
- Service definitions for load balancing
- ConfigMaps for environment-specific configuration
- Secrets for sensitive data
- Ingress for external access

## 🔍 Monitoring & Observability

### Application Metrics
- **Micrometer**: Metrics collection framework
- **Prometheus**: Metrics aggregation (when configured)
- **Grafana**: Metrics visualization (when configured)

### Health Checks
```bash
# Application health
curl http://localhost:8080/actuator/health

# Detailed health information
curl http://localhost:8080/actuator/health/diskSpace
curl http://localhost:8080/actuator/health/db
```

### Logging
- **SLF4J + Logback**: Structured logging
- **Log Levels**: DEBUG, INFO, WARN, ERROR
- **Log Rotation**: Automatic log file management
- **Centralized Logging**: ELK Stack compatible

## 🐛 Troubleshooting

### Common Issues

#### Database Connection Issues
```bash
# Check MySQL service
systemctl status mysql

# Test database connection
mysql -u bankapp_user -p -e "SELECT 1;"

# Check application logs
tail -f logs/application.log
```

#### Port Already in Use
```bash
# Find process using port 8080
lsof -i :8080

# Kill process
kill -9 <PID>

# Run on different port
java -jar target/bankapp-0.0.1-SNAPSHOT.jar --server.port=8081
```

#### Memory Issues
```bash
# Run with increased memory
java -Xmx2g -jar target/bankapp-0.0.1-SNAPSHOT.jar

# Monitor memory usage
jstat -gc <PID>
```

### Debug Mode
```bash
# Enable debug logging
java -jar target/bankapp-0.0.1-SNAPSHOT.jar --logging.level.com.example.bankapp=DEBUG

# Remote debugging
java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 -jar target/bankapp-0.0.1-SNAPSHOT.jar
```

## 📈 Performance Optimization

### JVM Tuning
```bash
# Production JVM settings
java -server \
  -Xms512m -Xmx1g \
  -XX:+UseG1GC \
  -XX:G1HeapRegionSize=16m \
  -XX:+UseStringDeduplication \
  -jar target/bankapp-0.0.1-SNAPSHOT.jar
```

### Database Optimization
- Connection pooling with HikariCP
- Query optimization and indexing
- Database connection limits
- Read/write splitting for scale

## 🤝 Contributing

### Getting Started
1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

### Code Review Process
- All changes require code review
- Automated tests must pass
- Code coverage must be maintained
- Documentation must be updated

### Development Workflow
1. **Issue Creation**: Create GitHub issue for bugs/features
2. **Branch Creation**: Create branch from main
3. **Development**: Write code and tests
4. **Testing**: Run full test suite
5. **Documentation**: Update relevant documentation
6. **Review**: Submit pull request for review

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Third-Party Licenses
- Spring Boot: Apache License 2.0
- MySQL Connector: GPL v2 with FOSS Exception
- Bootstrap: MIT License
- jQuery: MIT License

## 📞 Support & Contact

### Technical Support
- **Email**: support@bankapp.com
- **GitHub Issues**: [Create an issue](https://github.com/your-org/bankapp/issues)
- **Documentation**: [Wiki](https://github.com/your-org/bankapp/wiki)

### Development Team
- **Lead Developer**: Your Name (your.email@company.com)
- **Backend Team**: backend-team@company.com
- **DevOps Team**: devops@company.com

### Community
- **Slack**: #bankapp-development
- **Discord**: BankApp Community Server
- **Stack Overflow**: Tag questions with `spring-boot-bankapp`

## 🗺️ Roadmap

### Version 1.1 (Planned)
- [ ] Mobile app integration
- [ ] Advanced security features (2FA)
- [ ] Real-time notifications
- [ ] Enhanced reporting dashboard

### Version 1.2 (Future)
- [ ] Microservices architecture
- [ ] Blockchain integration
- [ ] AI-powered fraud detection
- [ ] Multi-language support

### Version 2.0 (Long-term)
- [ ] Open banking APIs
- [ ] Machine learning analytics
- [ ] Cloud-native architecture
- [ ] Advanced compliance features

---

## 📚 Additional Resources

- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Spring Security Reference](https://spring.io/projects/spring-security)
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [Docker Documentation](https://docs.docker.com/)
- [Maven User Guide](https://maven.apache.org/users/index.html)

**Happy Banking! 🏦💳**
