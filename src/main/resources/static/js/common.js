// 获取存储的token
function getToken() {
    return localStorage.getItem('token');
}

function getTenantCode() {
    return localStorage.getItem('tenantCode');
}

// 检查登录状态
function checkAuth() {
    const token = getToken();
    if (!token) {
        window.location.href = '/login.html';
        return false;
    }
    return true;
}

// 通用请求方法
async function request(url, options = {}) {
    const token = getToken();
    const tenantCode = getTenantCode();

    const defaultHeaders = {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
        'X-Tenant-Code': tenantCode
    };

    const response = await fetch(url, {
        ...options,
        headers: { ...defaultHeaders, ...options.headers }
    });

    if (response.status === 401) {
        localStorage.removeItem('token');
        localStorage.removeItem('tenantCode');
        window.location.href = '/login.html';
        throw new Error('请重新登录');
    }

    return response;
}

// 显示消息提示
function showMessage(message, type = 'success') {
    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.textContent = message;
    document.body.appendChild(toast);

    setTimeout(() => {
        toast.remove();
    }, 3000);
}

// 格式化日期
function formatDate(dateStr) {
    if (!dateStr) return '-';
    const date = new Date(dateStr);
    return date.toLocaleString('zh-CN');
}

// 获取状态文本
function getStatusText(status, type) {
    const statusMap = {
        asn: { 0: '待收货', 1: '收货中', 2: '已完成', 3: '已取消' },
        receiving: { 0: '待质检', 1: '质检中', 2: '已完成' }
    };
    return statusMap[type]?.[status] || '未知';
}

function getStatusClass(status) {
    if (status === 0) return 'status-pending';
    if (status === 1) return 'status-processing';
    if (status === 2) return 'status-completed';
    return '';
}

// 退出登录
function logout() {
    localStorage.removeItem('token');
    localStorage.removeItem('tenantCode');
    window.location.href = '/login.html';
}