# 09 - Billing Screens

## 1. Plan Comparison

**Purpose:** Compare available subscription plans with features and pricing.

**Layout:** Pricing table with feature comparison and plan selection.

**Key Components:**
- Plan cards (Free, Starter, Pro, Business, Enterprise)
- Monthly/Annual toggle with savings badge
- Feature comparison matrix
- "Current Plan" indicator
- "Upgrade" or "Downgrade" buttons
- Custom plan contact for Enterprise
- Feature limit indicators (posts, accounts, team members)
- Trial status (if applicable)
- Add-on options display

**Navigation:** From Settings > Billing or upgrade prompt.

**States:**
- Loading: Plan cards skeleton
- Error: "Could not load plans"
- Empty: N/A (always has plans)

**Responsive:** Plan cards stack on mobile, side-by-side on desktop.

---

## 2. Current Plan

**Purpose:** View details of current subscription plan with usage and next billing date.

**Layout:** Plan summary card with usage meters and billing details.

**Key Components:**
- Plan name and tier
- Monthly/annual billing indicator
- Next billing date and amount
- Usage meters (posts, accounts, team, storage, AI credits)
- "Upgrade" button
- "Cancel Subscription" link
- Billing history link
- Auto-renewal toggle
- Plan features list
- Usage alerts (approaching limits)

**Navigation:** From Settings > Billing or plan upgrade flow.

**States:**
- Loading: Plan details skeleton
- Error: "Could not load plan details"
- Empty: Free plan with no billing history

**Responsive:** Card layout on all sizes.

---

## 3. Upgrade/Downgrade

**Purpose:** Change subscription plan with proration and confirmation.

**Layout:** Plan selection, proration preview, and payment confirmation.

**Key Components:**
- Plan selector (current highlighted)
- Feature comparison between current and new
- Proration calculation (credit for downgrade, charge for upgrade)
- Payment method selector
- Confirmation checkbox
- "Confirm Change" button
- "Cancel" button
- Effective date display
- Feature availability timeline

**Navigation:** From Current Plan "Upgrade" or "Change Plan" buttons.

**States:**
- Loading: Proration calculation
- Error: "Could not calculate proration"
- Empty: N/A

**Responsive:** Full-width form on all sizes.

---

## 4. Payment Methods

**Purpose:** Manage saved payment methods (credit cards, PayPal, etc.).

**Layout:** List of payment methods with add/remove options.

**Key Components:**
- Payment method cards (type, last 4 digits, expiration)
- Default payment method indicator
- "Add Payment Method" button
- Remove payment method button
- Edit payment method button
- Payment method verification status
- Billing address display/edit
- Tax ID/VAT number input
- Payment method icons (Visa, Mastercard, Amex, PayPal)

**Navigation:** From Settings > Billing > Payment Methods.

**States:**
- Loading: Methods skeleton
- Error: "Could not load payment methods"
- Empty: "No payment methods" with add prompt

**Responsive:** List on all sizes.

---

## 5. Invoice History

**Purpose:** View all past invoices with download and payment status.

**Layout:** Table of invoices with filters and download options.

**Key Components:**
- Invoice table (date, amount, status, download)
- Status badges (Paid, Pending, Failed, Refunded)
- Download PDF button per invoice
- Send invoice via email button
- Invoice detail modal
- Filter by date range, status
- Search by invoice number
- Total paid summary
- Tax breakdown per invoice

**Navigation:** From Settings > Billing > Invoices.

**States:**
- Loading: Table skeleton
- Error: "Could not load invoices"
- Empty: "No invoices yet"

**Responsive:** Table scrolls horizontally on mobile.

---

## 6. Invoice Detail

**Purpose:** Detailed view of a single invoice with line items and payment info.

**Layout:** Invoice preview with line items, totals, and payment details.

**Key Components:**
- Invoice header (number, date, status)
- Line items table (description, quantity, amount)
- Subtotal, tax, total
- Payment method used
- Payment date
- Download PDF button
- Print button
- "Pay Now" button (if unpaid)
- Billing address
- Notes section

**Navigation:** From Invoice History row click.

**States:**
- Loading: Invoice skeleton
- Error: "Could not load invoice"
- Empty: N/A

**Responsive:** Full-width on all sizes.

---

## 7. AI Credits

**Purpose:** View AI credit balance, usage, and purchase options.

**Layout:** Credit balance display, usage breakdown, and purchase modal.

**Key Components:**
- Current credit balance (big number)
- Credits used this period
- Usage by feature (chart)
- Credit cost per feature table
- "Buy Credits" button
- Auto-purchase toggle (recharge when low)
- Usage history chart
- Credit expiration date
- Credit sharing (team allocation)

**Navigation:** From Settings > Billing > AI Credits or AI Studio header.

**States:**
- Loading: Credit data skeleton
- Error: "Could not load credit info"
- Empty: "No credits used yet"

**Responsive:** Metric cards stack on mobile.

---

## 8. Purchase Credits

**Purpose:** Buy additional AI credit packs with payment confirmation.

**Layout:** Credit pack selection, payment, and confirmation.

**Key Components:**
- Credit pack cards (amount, price, value badge)
- Custom amount input
- Payment method selector
- Order summary
- "Purchase" button
- Receipt confirmation
- Auto-recharge setup option
- Bulk discount tiers
- Gift credits option

**Navigation:** From AI Credits "Buy Credits" button.

**States:**
- Loading: Payment processing
- Error: "Purchase failed" with retry
- Empty: Pack selection

**Responsive:** Card grid on all sizes.

---

## 9. Usage Breakdown

**Purpose:** Detailed breakdown of all feature usage against plan limits.

**Layout:** Usage meters with detailed per-feature stats.

**Key Components:**
- Feature usage meters (progress bars)
- Posts created vs. limit
- Connected accounts vs. limit
- Team members vs. limit
- Storage used vs. limit
- AI credits used vs. balance
- Overage warnings
- Usage trend chart (30 days)
- "Upgrade" prompt when near limits
- Export usage report

**Navigation:** From Settings > Billing > Usage.

**States:**
- Loading: Usage data skeleton
- Error: "Could not load usage"
- Empty: "No usage recorded"

**Responsive:** Meters stack vertically on mobile.

---

## 10. Billing Settings

**Purpose:** Configure billing preferences, tax info, and subscription management.

**Layout:** Settings form with billing-specific options.

**Key Components:**
- Company name input
- Tax ID/VAT number input
- Billing email input
- Billing address form
- Currency selector
- Invoice language preference
- Auto-receipt emails toggle
- "Update Billing Info" button
- "Cancel Subscription" link
- "Pause Subscription" option
- Data retention after cancellation info
- Billing support contact

**Navigation:** From Settings > Billing > Settings.

**States:**
- Loading: Settings form skeleton
- Error: "Could not load billing settings"
- Empty: Default values shown

**Responsive:** Form stacks vertically on mobile.

---

## Screen Relationships

```
Plan Comparison → Upgrade/Downgrade
Current Plan → Upgrade/Downgrade → Payment Methods
Payment Methods → Billing Settings
Invoice History → Invoice Detail
AI Credits → Purchase Credits
Usage Breakdown → Plan Comparison (upgrade prompt)
Billing Settings → Cancel/Pause Subscription
```

## Design Tokens

- **Plan card width:** 280px
- **Plan card height:** 400px
- **Usage meter height:** 8px
- **Invoice row height:** 56px
- **Credit balance font:** 36px bold
- **Price font:** 24px bold
- **Badge height:** 24px
- **Table row height:** 48px
- **Spacing:** 8px base unit
