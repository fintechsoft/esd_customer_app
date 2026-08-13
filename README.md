# ESD Customer App

Flutter customer-facing app for Electronics Sales Delhi — OTP login, bill/order history,
product catalog, and support tickets. Built with GetX to match your existing ESD ERP app.

## 1. Backend setup (CI4)

1. Run `backend/sql/customer_app_migrations.sql` on your `aesms` database.
2. Copy the controllers into your CI4 project:
   - `backend/Controllers/Api/CustomerAuthController.php` → `app/Controllers/Api/`
   - `backend/Controllers/Api/CustomerOrderController.php` → `app/Controllers/Api/`
   - `backend/Controllers/Api/CustomerSupportController.php` → `app/Controllers/Api/`
   - `backend/Filters/CustomerApiAuth.php` → `app/Filters/`
3. Register the filter alias in `app/Config/Filters.php`:
   ```php
   public array $aliases = [
       // ...existing aliases
       'CustomerApiAuth' => \App\Filters\CustomerApiAuth::class,
   ];
   ```
4. Add the routes from `backend/routes_addition.php` into your existing
   `app/Config/Routes.php`, inside the `api` group (see comments in the file).
5. `CustomerAuthController::sendOtp()` currently calls your existing
   `WhatsAppController::sendOtpTest()` to deliver the code — confirm that
   method's signature matches `(string $phone, string $otp)`, or swap in
   your preferred SMS/WhatsApp sender.
6. Create `public/uploads/support/` (writable) for support ticket attachments.

## 2. Flutter app setup

```bash
flutter create --org com.yourcompany --project-name esdcustomer .   # if starting fresh
flutter pub get
```

Update `lib/config/api_constants.dart` → `baseUrl` to your live domain.

Run:
```bash
flutter run
```

## App flow

- **Splash** → checks stored token → **Login (mobile number)** → **OTP verify** → **Home**
- **Home**: quick actions (Products / Support / Bills) + recent bills
- **My Bills**: paginated order/bill history → tap for full bill detail, view PDF / delivery slip
- **Products**: catalog grid with search, reuses your existing public `api/products` /
  `api/product` endpoints — adjust the request body in `product_controller.dart` /
  `product_detail_controller.dart` to match whatever params `EnquiryController::getProducts`
  already expects
- **Support**: raise a ticket (category, subject, message, optional photo attachment),
  view status + admin replies
- **Profile**: customer info, logout

## Notes / assumptions made

- New `customer_tokens` table is used instead of reusing staff `api_tokens`, so customer
  sessions never collide with staff/app sessions.
- A customer who logs in with a phone number not yet in your `customer` table gets a new,
  minimal `customer` row auto-created (name defaults to "Customer" — prompt them to complete
  their profile after first login if you want that enforced).
- Order ownership is checked via `customer_id` on the `orders` table, so a customer can only
  ever see their own bills, never another customer's.
