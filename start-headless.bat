@echo off
cd /d "%~dp0"
echo ========================================
echo   北森疑似简历自动合并工具（无头模式）
echo   浏览器不可见，适合锁屏后运行
echo ========================================
echo.
echo 请先手动打开浏览器登录北森并进入列表页，
echo 然后回到此窗口按 Enter
echo.
pause
npx tsx src/index.ts --headless
pause
