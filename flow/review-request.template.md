# Review request — <task> — round <n>

Role: Reviewer (Claude, fresh session). Chỉ bắt đầu khi Lead đã nhận đồng ý của người dùng cho vòng này. Không sửa source; được ghi report và trạng thái trong .flow. Nếu được Orca giao, làm theo preamble và báo kết quả qua cơ chế điều phối.

Plan: <đường-dẫn-plan>
Base SHA: <base-commit>
Head SHA: <commit-cần-review>
Round: <n>
Previous review: <report hoặc none>
Previous reviewed SHA: <commit hoặc none>
Report: .flow/review.md

## Phạm vi và acceptance
- <file/chức năng, acceptance cần kiểm tra>
- <vòng sau: findings cần xác nhận, diff mới, ảnh hưởng liên quan>

## Verify
```sh
<lệnh chính xác và điều kiện môi trường>
```

Đọc plan và rules repo, kiểm tra đúng base/head, không có checkout đang đổi; repo có quyền ưu tiên. Đọc diff và code liên quan, acceptance, phạm vi và tests. Chạy kiểm tra theo skill `scoped-verify` (chọn test theo diff từ previous reviewed SHA; đủ bộ/Postgres chỉ ở vòng cuối hoặc khi đụng DB/migration), trừ khi plan/rules bắt buộc khác, ghi lệnh, exit code và bằng chứng; kiểm tra đỏ/không chạy được phải nói rõ, không báo PASS. Không dùng trạng thái built thay cho bằng chứng.

Report cần:
```text
Verdict: PASS hoặc CHANGES
Reviewed SHA: <commit-thực-tế-đã-review>
Blocking findings:
- file:line — vấn đề — cách sửa
Optional suggestions:
- <góp ý không chặn>
Checks:
- <lệnh> → <exit code, pass/fail, log>
Limitations:
- <phần chưa xác minh>
```

Lỗi chức năng, dữ liệu, bảo mật, accessibility, acceptance/rules hoặc bằng chứng thiếu có thể chặn. Sở thích phong cách không có tác hại cụ thể là tùy chọn. Cập nhật plan `Status: review-pass` khi PASS hoặc `Status: changes` khi CHANGES; không commit source/push/merge. Không tự tạo Reviewer khác.
