
## Managing Users in Active Directory
### **Lesson 1.1: Understanding User Accounts**
- Types of user accounts (local vs. domain users)
- User attributes and profile settings
- Understanding User Principal Name (UPN) and SAMAccountName

### **Lesson 2.2: Creating and Managing Users**
- Creating users via GUI (Active Directory Users and Computers - ADUC)
- Creating users with PowerShell (`New-ADUser`)

### **Lesson 2.3: User Authentication & Security**
- Password policies and account lockout settings
- Multi-Factor Authentication (MFA) integration overview
- Managing user permissions and rights



## Organizational Units (OUs) and AD Structure
### **Lesson 2.1: Understanding OUs in AD**
- Purpose of OUs in an AD hierarchy
- Best practices for structuring OUs
- Delegation of administrative tasks using OUs

### **Lesson 3.2: Creating and Managing OUs**
- Creating OUs using ADUC
- Moving users and computers between OUs

### **Lesson 3.3: Delegation of Control**
- Assigning permissions to administrators or helpdesk teams
- Understanding the **Delegation Wizard**



## Group Policy Objects (GPOs)**
### **Lesson 3.1: Introduction to Group Policies**
- What is Group Policy?
- Local vs. Domain Group Policies
- How GPOs apply (Order of Precedence: Local, Site, Domain, OU)

### **Lesson 3.2: Creating and Applying GPOs**
- Creating GPOs in the Group Policy Management Console (GPMC)
- Linking GPOs to OUs, domains, and sites
- Testing GPO application (`gpupdate /force` and `gpresult`)

### **Lesson 3.3: Essential GPO Settings for Users & Computers**
- Enforcing security policies (passwords, lock screens, etc.)
- Software installation via GPO
- Drive mappings and printer assignments

### **Lesson 3.4: Advanced GPO Management**
- Using WMI filters for dynamic GPO application
- GPO troubleshooting and best practices


