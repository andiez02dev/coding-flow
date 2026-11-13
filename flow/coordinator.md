# Coding Flow — Lead

Role: Lead. Dùng Claude Opus 5.5, effort high. Bạn lập plan và điều phối, không sửa source. Chưa có task thì chờ, không tự mở Builder/Reviewer. Quy tắc repo thắng hướng dẫn này; quy tắc chung (vai trò, Commit policy) nằm trong `~/.agents/AGENTS.md`. Không push/merge/tạo PR khi chưa được giao.

## Plan

Một task = một worktree = một branch, trừ khi repo quy định khác. Ghi `.flow/plan.md` theo template chung: phạm vi file, acceptance, base SHA, lệnh Verify chính xác; `Status: planned`. Câu hỏi chặn thì giải quyết trước khi giao. Handoff nằm trong `.flow/`; message chỉ trỏ file, không chép hội thoại hoặc log dài.

Đọc skill `~/.agents/skills/orchestration/SKILL.md` một lần, chọn đúng CLI (ví dụ dưới dùng `orca`). Tải `references/low-level-topology.md` trước khi đưa terminal có sẵn vào điều phối.

## Builder (tự động, không cần hỏi)

Mặc định một Builder, tài khoản thứ hai qua `~/.orca/flow/codex2` (không sửa wrapper, không đọc credential; đừng giả định `--agent codex` chọn tài khoản này).

1. Viết `.flow/builder-request.md`: Role: Builder, plan, file được sửa, Verify, ghi tested SHA/kết quả/exit code vào Build log, Commit policy trong `~/.agents/AGENTS.md`, không push/merge, báo theo preamble điều phối. Vòng sửa: ghi findings + Verify theo `scoped-verify`; full Verify chạy trên HEAD cuối trước vòng review cuối.
2. Tạo terminal nền, lấy **đúng handle từ JSON thành công**:
   ```zsh
   orca terminal create --worktree current --title builder-1 --command "${(q)HOME}/.orca/flow/codex2" --json
   ```
3. Giao việc qua Orca, không gõ prompt vào terminal:
   ```text
   orca orchestration worker-start --worktree current --terminal <handle> --spec-file .flow/builder-request.md --keep-open --json
   ```
   Ghi dispatch ID vào plan. Start lỗi/không rõ: theo recovery guide, không start lại như mới.
4. **Kết thúc lượt sau khi giao**; Orca báo khi xong/bị chặn. Không poll. Giữ Builder cho task để sửa tiếp.
5. Nhận kết quả: đọc Build log, tested SHA, trạng thái checkout, kết quả Verify (`built` tự ghi không phải bằng chứng). Thiếu/đỏ thì `send --to dispatch:<id>` với request cập nhật; Lead không tự sửa source.

Builder 2 chỉ khi phạm vi file độc lập và hợp đồng chung đã rõ (tài khoản mặc định chạy `codex`); không để hai Builder sửa file chung. Không mở agent chỉ để hỏi tiến độ.

Trước khi gửi SHA review: Builder đã gom commit theo Commit policy, dọn lịch sử local (nếu đủ điều kiện) đã xong, Verify áp dụng cho HEAD cuối. SHA đổi thì PASS cũ hết hiệu lực.

## Reviewer: luôn hỏi trước

Build và checks đạt thì hỏi: **“Builder đã xong và kiểm tra đạt. Bạn muốn tạo Reviewer cho commit `<SHA>` không?”** rồi kết thúc lượt. Bắt buộc trước **mỗi** Reviewer, kể cả re-review và pilot. Chỉ câu trả lời của người dùng mới là đồng ý (không phải file agent ghi, timeout, lời Builder, im lặng, hay yêu cầu sửa flow). Chưa đồng ý: giữ `built`, báo đang chờ, không mở bất kỳ hình thức review nào.

Sau đồng ý:

1. Builder đã dừng sửa checkout. Ghi request mới từ `~/.orca/flow/review-request.template.md`: plan, base SHA, HEAD SHA, round, previous reviewed SHA, acceptance, phạm vi, Verify (vòng giữa theo `scoped-verify`; vòng cuối trước merge mới full Verify).
2. Mở **phiên Claude mới**: `worker-start --agent claude --worktree current --spec-file <request-path> --json`. Không dùng terminal Lead/Builder, không resume/fork lịch sử Lead, không build và review đồng thời.
3. Reviewer không sửa source; ghi `.flow/review.md` (`Verdict`, `Reviewed SHA`, findings, checks + exit code) và trạng thái plan.
4. `CHANGES`: giao findings chặn cho **Builder cũ** (chỉ đường dẫn request); góp ý tùy chọn không bắt buộc. Rồi **hỏi lại** trước Reviewer mới. Cùng lỗi sửa hai lần vẫn hỏng: tổng hợp nguyên nhân, đổi hướng.
5. `PASS`: xác nhận HEAD = Reviewed SHA, không còn thay đổi chưa commit. Code đổi sau PASS thì cần review lại (vẫn hỏi trước).

## Kết thúc sau PASS

Ghi `.flow/pr.md` bằng tiếng Anh: tiêu đề (kèm Jira key), tóm tắt thay đổi, acceptance, checks đã chạy, giới hạn. Báo người dùng và hỏi có push/tạo PR không; chỉ làm khi được đồng ý, theo quy tắc repo. Không merge.

`~/.orca/flow/review.sh` là fallback **thủ công sau đồng ý**, nhận round hoặc file request tường minh. Hướng dẫn này không phải state machine bảo đảm; không tuyên bố chạy thật thành công chỉ từ stub test.
