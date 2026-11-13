# Coding Flow

Mở flow cho một worktree bất kỳ đã có trong Orca:

```sh
~/.orca/flow/layout.sh /đường/dẫn/worktree
~/.orca/flow/layout.sh /đường/dẫn/worktree "Tên riêng"
```

Mặc định có **Lead + tracker**, tên `Coding Flow · <tên thư mục>`. Lead dùng **Claude Opus 5.5 · high** và đọc hướng dẫn điều phối ngay lúc khởi động. Chưa có task thì Lead chờ bạn giao việc. Mở flow không tự chuyển focus; các terminal cũ không bị đóng hoặc đổi cấu hình.

Bạn giao việc → Lead lập plan → tự gọi một Builder → nhận kết quả/kiểm tra → **hỏi bạn trước khi tạo Reviewer**. Mỗi vòng review lại cũng phải được bạn đồng ý. Reviewer là Claude mới, không sửa source. Builder giữ phiên trong cả task; chỉ gọi Builder thứ hai khi chia được trách nhiệm độc lập. Không push/merge nếu bạn chưa giao.

Builder chính dùng tài khoản thứ hai qua `codex2`; Builder thứ hai khi cần dùng tài khoản mặc định. Wrapper tài khoản và cấu hình model toàn máy không bị sửa. Chạy script cần zsh, python3, Orca, Claude và Codex đã được thiết lập/đăng nhập.

Quy tắc commit: gom sửa liên quan thành một đợt đã kiểm tra, không commit từng comment PR; không ép một ticket chỉ có một commit. Chỉ dọn lịch sử local của nhánh task chưa publish/chia sẻ trước khi bàn giao SHA review. Giữ lịch sử đã push, `main` và các bug độc lập; không force-push. Quy tắc riêng của repo vẫn được ưu tiên. Quy tắc đầy đủ nằm trong `~/.agents/AGENTS.md`, mục Commit policy.

Bố cục thủ công 4 pane cũ:

```sh
~/.orca/flow/manual-layout.sh /đường/dẫn/worktree
```

Sau khi đồng ý review, có thể mở Reviewer thủ công bằng round hoặc file request chính xác:

```sh
~/.orca/flow/review.sh /đường/dẫn/worktree 1
~/.orca/flow/review.sh /đường/dẫn/worktree .flow/task/review-request-r2.md
```

Không còn tự chọn request mới nhất khi thiếu đối số. Helper thủ công không tự báo kết quả về Lead; cách điều phối trong `coordinator.md` dùng cơ chế nhận kết quả của Orca. Hướng dẫn agent yêu cầu hỏi trước, nhưng helper không tự xác minh đối thoại hoặc cưỡng chế consent bằng chương trình.

Trong worktree triển khai, chạy `python3 verify_flow.py` và `zsh -n layout.sh manual-layout.sh review.sh track.sh codex2`. Lệnh `zsh -n` cần chạy riêng từng file để kiểm tra đủ cả năm script. Kiểm tra dùng executable stub ở ranh giới Orca, không gọi AI hoặc mở UI thật. Kiểm tra không chứng minh callback, tài khoản đăng nhập, model thực tế hay toàn bộ vòng build/review hoạt động. Chưa có số đo tiết kiệm token.

## Khôi phục

Bản gốc và manifest nằm trong `.flow/live-backup` của worktree triển khai; đường dẫn chính xác được ghi trong `.flow/build-result.md`. Trước khôi phục, so manifest với file đang cài để tránh ghi đè chỉnh sửa mới của bạn. Khôi phục `layout.sh` và `review.sh` từ backup, giữ quyền executable. Các file mới chỉ xóa khi bạn muốn; `track.sh` và `codex2` không bị thay đổi. Không ghi đè terminal đang chạy: thay đổi có hiệu lực khi mở flow mới.
