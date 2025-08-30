# Paw Care 🐶

### Paw Care is an Android application built with Flutter that helps pet owners manage their pet's health and well-being. The app allows users to, 

*   Track and set medicine reminders
*   Predict potential health issues based on symptoms using a machine learning model
*   Set goals for their pet's health
*   Find local veterinary services

The app uses Firebase for user authentication and data storage. It also utilizes a TensorFlow Lite model for predicting pet health issues.

# AI-Powered Pet Care Features

## Intelligent Pet Health Monitoring

PAWCARE integrates artificial intelligence to revolutionize pet healthcare through smart detection and predictive analytics. Our AI-powered features transform your smartphone into a comprehensive pet health monitoring system.

### Core AI Capabilities 

- **Symptom Recognition**: AI models trained on veterinary data identify potential health concerns from behavioral patterns and physical symptoms

### Technical Implementation

**Machine Learning Stack**
- **TensorFlow Lite**: Optimized on-device inference for real-time pet health analysis
- **Edge Computing**: Local AI processing ensures data privacy while maintaining fast response times

### Privacy-First AI

All AI processing occurs locally on your device, ensuring your pet's health data remains private and secure. Our edge-computing approach delivers intelligent insights without compromising sensitive information about your beloved companion.

# CI/CD Pipeline

This project implements a robust CI/CD pipeline using GitHub Actions that ensures code quality, automated testing, and reliable builds for the PAWCARE Flutter mobile application.

## Pipeline Architecture

### Trigger Events
- **Push to main branch**: Automatically validates and builds production-ready releases
- **Pull requests**: Validates proposed changes before merging to maintain code quality
- **Manual dispatch**: Supports on-demand pipeline execution for deployment scenarios

### Build Environment
- **Platform**: Ubuntu Latest (Linux-based container)
- **Flutter SDK**: Stable channel with automatic version management
- **Caching Strategy**: Intelligent dependency caching reduces build times by 60-70%
- **Secret Management**: Secure handling of Firebase configuration and API keys

## Pipeline Stages
1. Code Validation
2. Testing Framework
3. Build Process
4. Artifact Management

# Dependencies and Compatibility
- **Android Gradle Plugin**: Version 8.6.0+ for latest Android features
- **Kotlin**: Version 2.1.0 for enhanced compilation performance  
- **Flutter**: Stable channel with automatic SDK management
- **Firebase**

## Emulator Testing
The pipeline includes conditional Android emulator execution:
- **API Level 33**: Target Android 13 compatibility
- **Architecture**: x86_64 for optimal CI performance
- **Device Profile**: Nexus 6 for representative screen testing
- **KVM Acceleration**: Hardware-accelerated virtualization

### Build Optimization
- **Code Shrinking**: R8 optimization with ML library preservation
- **Resource Optimization**: Automatic asset and font tree-shaking
- **Multi-architecture Support**: ARM64 and x86_64 APK generation

## Security Measures
- **Secret Management**: Encrypted storage of Firebase configuration
- **Dependency Scanning**: Automated vulnerability detection

## Maintenance
- **Weekly Dependency Updates**: Automated dependency freshness checks
- **Flutter Version Tracking**: Automatic SDK version management
- **Performance Monitoring**: Build time and resource usage analytics
- **Dependency Vulnerabilities Assessment**: Weekly vulnerability assessments and update recommendations

# 🔧 Modifying the Codebase

In cases where modifications to the codebase are intended (e.g., to address issues or implement enhancements), a new Firebase project should be created under your own account, and the corresponding google-services.json file should be placed within the android/app directory.
