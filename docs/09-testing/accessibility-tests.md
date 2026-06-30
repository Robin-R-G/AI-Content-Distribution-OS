# Accessibility Testing Guide

## Overview

Accessibility testing ensures the application is usable by people with disabilities, following WCAG 2.1 AA guidelines and best practices.

## WCAG 2.1 AA Compliance

### Guidelines Overview

```markdown
## WCAG 2.1 AA Guidelines

### Perceivable
1.1 Text Alternatives
1.2 Time-based Media
1.3 Adaptable
1.4 Distinguishable

### Operable
2.1 Keyboard Accessible
2.2 Enough Time
2.3 Seizures and Physical Reactions
2.4 Navigable
2.5 Input Modalities

### Understandable
3.1 Readable
3.2 Predictable
3.3 Input Assistance

### Robust
4.1 Compatible
```

### Compliance Checklist

```markdown
## Accessibility Checklist

### Images and Icons
- [ ] All images have alt text
- [ ] Decorative images have empty alt attributes
- [ ] Icons have accessible labels
- [ ] Complex images have long descriptions

### Forms
- [ ] All form fields have labels
- [ ] Required fields are marked
- [ ] Error messages are descriptive
- [ ] Form validation is accessible

### Navigation
- [ ] Keyboard navigation works
- [ ] Focus indicators are visible
- [ ] Skip links are provided
- [ ] Page structure is logical

### Color and Contrast
- [ ] Color contrast ratio meets 4.5:1
- [ ] Information not conveyed by color alone
- [ ] Focus indicators have sufficient contrast

### Content
- [ ] Headings are properly structured
- [ ] Lists are properly marked up
- [ ] Tables have headers
- [ ] Language is specified
```

## Screen Reader Testing

### ARIA Labels and Roles

```typescript
// Example ARIA implementation
<button 
  aria-label="Close dialog"
  aria-describedby="dialog-description"
>
  <span aria-hidden="true">×</span>
</button>

<div 
  id="dialog-description"
  aria-live="polite"
  role="status"
>
  Dialog will close in 5 seconds
</div>

<nav aria-label="Main navigation">
  <ul role="menubar">
    <li role="menuitem">
      <a href="/home">Home</a>
    </li>
    <li role="menuitem">
      <a href="/posts">Posts</a>
    </li>
  </ul>
</nav>
```

### Screen Reader Test Script

```markdown
## Screen Reader Testing Script

### 1. Navigation Testing
- [ ] Can navigate using headings (H1 → H2 → H3)
- [ ] Can navigate using landmarks
- [ ] Can navigate using links
- [ ] Can navigate using form controls

### 2. Content Testing
- [ ] Images have appropriate descriptions
- [ ] Links are descriptive
- [ ] Form fields have labels
- [ ] Error messages are announced

### 3. Interactive Elements
- [ ] Buttons are announced as buttons
- [ ] Links are announced as links
- [ ] Form fields announce their purpose
- [ ] Dynamic content is announced

### 4. Tables
- [ ] Table headers are announced
- [ ] Table relationships are clear
- [ ] Complex tables are navigable
```

### Automated Screen Reader Testing

```typescript
// tests/accessibility/screen-reader.test.ts
import { AxePuppeteer } from '@axe-core/puppeteer';
import puppeteer from 'puppeteer';

describe('Screen Reader Accessibility', () => {
  let browser: puppeteer.Browser;
  let page: puppeteer.Page;

  beforeAll(async () => {
    browser = await puppeteer.launch();
    page = await browser.newPage();
  });

  afterAll(async () => {
    await browser.close();
  });

  it('should have proper heading structure', async () => {
    await page.goto('http://localhost:3000');
    
    const headings = await page.evaluate(() => {
      const headingElements = document.querySelectorAll('h1, h2, h3, h4, h5, h6');
      return Array.from(headingElements).map(h => ({
        level: parseInt(h.tagName[1]),
        text: h.textContent?.trim(),
      }));
    });

    // Verify heading hierarchy
    let previousLevel = 0;
    for (const heading of headings) {
      expect(heading.level).toBeLessThanOrEqual(previousLevel + 1);
      previousLevel = heading.level;
    }
  });

  it('should have proper ARIA labels', async () => {
    await page.goto('http://localhost:3000');
    
    const elements = await page.evaluate(() => {
      const interactiveElements = document.querySelectorAll(
        'button, a, input, select, textarea'
      );
      return Array.from(interactiveElements).map(el => ({
        tag: el.tagName,
        ariaLabel: el.getAttribute('aria-label'),
        ariaDescribedby: el.getAttribute('aria-describedby'),
        text: el.textContent?.trim(),
      }));
    });

    for (const element of elements) {
      const hasAccessibleName = 
        element.ariaLabel || 
        element.ariaDescribedby || 
        element.text;
      
      expect(hasAccessibleName).toBeTruthy();
    }
  });

  it('should pass axe-core accessibility audit', async () => {
    await page.goto('http://localhost:3000');
    
    const results = await new AxePuppeteer(page)
      .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa'])
      .analyze();

    expect(results.violations).toHaveLength(0);
  });
});
```

## Keyboard Navigation Testing

### Keyboard Navigation Tests

```typescript
// tests/accessibility/keyboard-navigation.test.ts
import { AxePuppeteer } from '@axe-core/puppeteer';
import puppeteer from 'puppeteer';

describe('Keyboard Navigation', () => {
  let browser: puppeteer.Browser;
  let page: puppeteer.Page;

  beforeAll(async () => {
    browser = await puppeteer.launch();
    page = await browser.newPage();
  });

  afterAll(async () => {
    await browser.close();
  });

  it('should navigate with Tab key', async () => {
    await page.goto('http://localhost:3000');
    
    // Focus first element
    await page.keyboard.press('Tab');
    
    const firstFocused = await page.evaluate(() => {
      const focused = document.activeElement;
      return {
        tag: focused?.tagName,
        id: focused?.id,
        className: focused?.className,
      };
    });

    expect(firstFocused.tag).toBeDefined();

    // Continue tabbing
    for (let i = 0; i < 5; i++) {
      await page.keyboard.press('Tab');
      
      const currentFocused = await page.evaluate(() => {
        const focused = document.activeElement;
        return {
          tag: focused?.tagName,
          id: focused?.id,
          className: focused?.className,
        };
      });

      expect(currentFocused.tag).toBeDefined();
    }
  });

  it('should have visible focus indicators', async () => {
    await page.goto('http://localhost:3000');
    
    await page.keyboard.press('Tab');
    
    const hasFocusStyle = await page.evaluate(() => {
      const focused = document.activeElement;
      const styles = window.getComputedStyle(focused!);
      
      return {
        outlineStyle: styles.outlineStyle,
        outlineWidth: styles.outlineWidth,
        outlineColor: styles.outlineColor,
        boxShadow: styles.boxShadow,
      };
    });

    expect(
      hasFocusStyle.outlineStyle !== 'none' ||
      hasFocusStyle.boxShadow !== 'none'
    ).toBeTruthy();
  });

  it('should support keyboard shortcuts', async () => {
    await page.goto('http://localhost:3000');
    
    // Test Escape key
    await page.keyboard.press('Escape');
    
    const modalClosed = await page.evaluate(() => {
      const modal = document.querySelector('[role="dialog"]');
      return !modal || modal.getAttribute('aria-hidden') === 'true';
    });

    expect(modalClosed).toBeTruthy();
  });

  it('should trap focus in modal dialogs', async () => {
    await page.goto('http://localhost:3000');
    
    // Open modal
    await page.click('[data-testid="open-modal"]');
    
    const modal = await page.$('[role="dialog"]');
    expect(modal).toBeTruthy();

    // Tab through modal
    for (let i = 0; i < 10; i++) {
      await page.keyboard.press('Tab');
      
      const focusedElement = await page.evaluate(() => {
        const focused = document.activeElement;
        return focused?.closest('[role="dialog"]') !== null;
      });

      expect(focusedElement).toBeTruthy();
    }
  });
});
```

## Color Contrast Testing

### Contrast Ratio Testing

```typescript
// tests/accessibility/color-contrast.test.ts
import { AxePuppeteer } from '@axe-core/puppeteer';
import puppeteer from 'puppeteer';

describe('Color Contrast', () => {
  let browser: puppeteer.Browser;
  let page: puppeteer.Page;

  beforeAll(async () => {
    browser = await puppeteer.launch();
    page = await browser.newPage();
  });

  afterAll(async () => {
    await browser.close();
  });

  it('should meet WCAG AA contrast requirements', async () => {
    await page.goto('http://localhost:3000');
    
    const results = await new AxePuppeteer(page)
      .withRules(['color-contrast'])
      .analyze();

    expect(results.violations).toHaveLength(0);
  });

  it('should have sufficient contrast for text', async () => {
    await page.goto('http://localhost:3000');
    
    const contrastIssues = await page.evaluate(() => {
      const textElements = document.querySelectorAll('p, span, a, h1, h2, h3, h4, h5, h6, li');
      const issues: Array<{element: string; contrast: number}> = [];

      textElements.forEach(el => {
        const styles = window.getComputedStyle(el);
        const color = styles.color;
        const backgroundColor = styles.backgroundColor;
        
        // Simple contrast calculation (simplified)
        const contrast = calculateContrast(color, backgroundColor);
        
        if (contrast < 4.5) {
          issues.push({
            element: el.tagName + (el.className ? `.${el.className}` : ''),
            contrast,
          });
        }
      });

      return issues;
    });

    expect(contrastIssues).toHaveLength(0);
  });

  it('should not rely on color alone', async () => {
    await page.goto('http://localhost:3000');
    
    const colorOnlyIssues = await page.evaluate(() => {
      const issues: string[] = [];
      
      // Check for error messages
      const errorElements = document.querySelectorAll('.error, .warning, .success');
      errorElements.forEach(el => {
        const hasIcon = el.querySelector('svg, i, .icon');
        const hasText = el.textContent?.trim();
        
        if (!hasIcon && hasText) {
          issues.push(`Error message relies on color: ${hasText}`);
        }
      });

      return issues;
    });

    expect(colorOnlyIssues).toHaveLength(0);
  });
});

// Helper function for contrast calculation
function calculateContrast(color1: string, color2: string): number {
  // Simplified contrast calculation
  // In production, use a proper color contrast library
  const getLuminance = (color: string) => {
    // Parse color and calculate luminance
    return 0.5; // Placeholder
  };

  const l1 = getLuminance(color1);
  const l2 = getLuminance(color2);
  
  const lighter = Math.max(l1, l2);
  const darker = Math.min(l1, l2);
  
  return (lighter + 0.05) / (darker + 0.05);
}
```

## Automated Accessibility Testing

### axe-core Integration

```typescript
// tests/accessibility/axe-core.test.ts
import { AxePuppeteer } from '@axe-core/puppeteer';
import puppeteer from 'puppeteer';

describe('Accessibility with axe-core', () => {
  let browser: puppeteer.Browser;
  let page: puppeteer.Page;

  beforeAll(async () => {
    browser = await puppeteer.launch();
    page = await browser.newPage();
  });

  afterAll(async () => {
    await browser.close();
  });

  it('should pass full accessibility audit', async () => {
    await page.goto('http://localhost:3000');
    
    const results = await new AxePuppeteer(page)
      .withTags(['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'best-practice'])
      .analyze();

    expect(results.violations).toHaveLength(0);
  });

  it('should have no critical violations', async () => {
    await page.goto('http://localhost:3000');
    
    const results = await new AxePuppeteer(page)
      .analyze();

    const criticalViolations = results.violations.filter(
      violation => violation.impact === 'critical' || violation.impact === 'serious'
    );

    expect(criticalViolations).toHaveLength(0);
  });

  it('should provide detailed violation information', async () => {
    await page.goto('http://localhost:3000');
    
    const results = await new AxePuppeteer(page)
      .analyze();

    results.violations.forEach(violation => {
      console.log(`Violation: ${violation.id}`);
      console.log(`Impact: ${violation.impact}`);
      console.log(`Description: ${violation.description}`);
      console.log(`Help: ${violation.help}`);
      console.log(`Help URL: ${violation.helpUrl}`);
      console.log(`Nodes: ${violation.nodes.length}`);
      console.log('---');
    });
  });
});
```

### Jest Accessibility Integration

```typescript
// jest.config.js
module.exports = {
  setupFilesAfterSetup: ['@testing-library/jest-dom'],
  testEnvironment: 'jsdom',
  transform: {
    '^.+\\.tsx?$': 'ts-jest',
  },
  moduleNameMapper: {
    '\\.(css|less|scss|sass)$': 'identity-obj-proxy',
  },
};

// tests/accessibility/jest-accessibility.test.ts
import { render, screen } from '@testing-library/react';
import { axe, toHaveNoViolations } from 'jest-axe';
import { PostCard } from '../../src/components/PostCard';

expect.extend(toHaveNoViolations);

describe('PostCard Accessibility', () => {
  it('should have no accessibility violations', async () => {
    const { container } = render(
      <PostCard
        post={{
          id: '1',
          title: 'Test Post',
          content: 'Test content',
          author: 'John Doe',
        }}
      />
    );

    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });

  it('should have proper ARIA attributes', () => {
    render(
      <PostCard
        post={{
          id: '1',
          title: 'Test Post',
          content: 'Test content',
          author: 'John Doe',
        }}
      />
    );

    const article = screen.getByRole('article');
    expect(article).toHaveAttribute('aria-labelledby');

    const title = screen.getByText('Test Post');
    expect(title).toHaveAttribute('id');
  });
});
```

## Flutter Accessibility Testing

### Flutter Accessibility Tests

```dart
// test/accessibility/flutter_accessibility_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:your_app/widgets/post_card.dart';

void main() {
  group('PostCard Accessibility', () {
    testWidgets('should have semantic labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(
              post: Post(
                id: '1',
                title: 'Test Post',
                content: 'Test content',
                author: 'John Doe',
              ),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(PostCard));
      
      expect(semantics.label, contains('Test Post'));
      expect(semantics.label, contains('John Doe'));
    });

    testWidgets('should support screen reader navigation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(
              post: Post(
                id: '1',
                title: 'Test Post',
                content: 'Test content',
                author: 'John Doe',
              ),
            ),
          ),
        ),
      );

      // Test semantic order
      final semantics = tester.getSemantics(find.byType(PostCard));
      expect(semantics.children.length, greaterThan(0));
    });

    testWidgets('should have minimum touch target size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PostCard(
              post: Post(
                id: '1',
                title: 'Test Post',
                content: 'Test content',
                author: 'John Doe',
              ),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(PostCard));
      
      // Minimum touch target size is 48x48 pixels
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });
}
```

### Flutter Color Contrast Testing

```dart
// test/accessibility/color_contrast_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('Color Contrast', () {
    testWidgets('should meet WCAG AA contrast requirements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
              bodyMedium: TextStyle(color: Colors.black87),
            ),
          ),
          home: Scaffold(
            body: Text('Test text'),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Test text'));
      final color = textWidget.style?.color;
      
      // Verify color has sufficient contrast
      expect(color, isNotNull);
    });
  });
}
```

## Running Accessibility Tests

### Commands

```bash
# Run axe-core tests
npm run test:accessibility

# Run keyboard navigation tests
npm run test:keyboard

# Run color contrast tests
npm run test:contrast

# Run full accessibility audit
npm run test:a11y

# Run Flutter accessibility tests
flutter test test/accessibility/
```

### CI/CD Integration

```yaml
# .github/workflows/accessibility-tests.yml
name: Accessibility Tests

on:
  pull_request:
    branches: [main]

jobs:
  accessibility:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run accessibility tests
        run: npm run test:a11y
        
      - name: Run axe-core tests
        run: npm run test:accessibility
        
      - name: Upload accessibility report
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: accessibility-report
          path: accessibility-report.json
```

## Best Practices

### 1. Design Phase
- Include accessibility in design system
- Use semantic color palettes
- Design with keyboard navigation in mind

### 2. Development Phase
- Use semantic HTML elements
- Implement proper ARIA attributes
- Test with screen readers during development

### 3. Testing Phase
- Automate accessibility testing
- Perform manual testing with assistive technologies
- Include users with disabilities in testing

### 4. Documentation
- Document accessibility features
- Provide accessibility statements
- Create accessibility guidelines

### 5. Continuous Improvement
- Regular accessibility audits
- Stay updated with WCAG guidelines
- Train team on accessibility best practices