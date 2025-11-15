import { useQuotas } from '../hooks/useQuotas'

export function QuotaDashboard() {
  const { quotas, loading, error } = useQuotas()

  if (loading) {
    return (
      <div className="card">
        <div className="animate-pulse">
          <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-1/4 mb-4"></div>
          <div className="space-y-3">
            <div className="h-24 bg-gray-200 dark:bg-gray-700 rounded"></div>
            <div className="h-24 bg-gray-200 dark:bg-gray-700 rounded"></div>
            <div className="h-24 bg-gray-200 dark:bg-gray-700 rounded"></div>
          </div>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="card bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800">
        <p className="text-red-800 dark:text-red-200">Error loading quotas: {error.message}</p>
      </div>
    )
  }

  if (quotas.length === 0) {
    return (
      <div className="card">
        <p className="text-gray-500 dark:text-gray-400 text-center">
          No accounts configured yet. Add your first account to get started.
        </p>
      </div>
    )
  }

  return (
    <div className="space-y-4">
      <h2 className="text-2xl font-bold text-gray-900 dark:text-white">Quota Usage</h2>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {quotas.map((quota) => {
          const dailyPercentage = Math.min((quota.daily_used / quota.daily_limit) * 100, 100)
          const monthlyPercentage = quota.monthly_limit
            ? Math.min((quota.monthly_used / (quota.monthly_limit || 1)) * 100, 100)
            : null

          const getStatusColor = (percentage: number) => {
            if (percentage >= 90) return 'bg-red-500'
            if (percentage >= 70) return 'bg-yellow-500'
            return 'bg-green-500'
          }

          return (
            <div key={quota.id} className="card">
              <div className="flex items-center justify-between mb-2">
                <h3 className="text-lg font-semibold capitalize text-gray-900 dark:text-white">
                  {quota.provider}
                </h3>
                <span
                  className={`badge ${
                    quota.accounts?.status === 'active'
                      ? 'badge-success'
                      : quota.accounts?.status === 'expired'
                      ? 'badge-error'
                      : 'badge-warning'
                  }`}
                >
                  {quota.accounts?.status}
                </span>
              </div>

              <p className="text-sm text-gray-600 dark:text-gray-400 mb-4">
                {quota.accounts?.email}
              </p>

              {/* Daily Quota */}
              <div className="mb-3">
                <div className="flex justify-between text-sm mb-1">
                  <span className="text-gray-600 dark:text-gray-400">Daily</span>
                  <span className="font-medium text-gray-900 dark:text-white">
                    {quota.daily_used} / {quota.daily_limit}
                  </span>
                </div>
                <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
                  <div
                    className={`h-2 rounded-full transition-all ${getStatusColor(dailyPercentage)}`}
                    style={{ width: `${dailyPercentage}%` }}
                  />
                </div>
              </div>

              {/* Monthly Quota (if available) */}
              {quota.monthly_limit && monthlyPercentage !== null && (
                <div>
                  <div className="flex justify-between text-sm mb-1">
                    <span className="text-gray-600 dark:text-gray-400">Monthly</span>
                    <span className="font-medium text-gray-900 dark:text-white">
                      {quota.monthly_used} / {quota.monthly_limit}
                    </span>
                  </div>
                  <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
                    <div
                      className={`h-2 rounded-full transition-all ${getStatusColor(monthlyPercentage)}`}
                      style={{ width: `${monthlyPercentage}%` }}
                    />
                  </div>
                </div>
              )}

              <p className="text-xs text-gray-500 dark:text-gray-400 mt-3">
                Resets: {new Date(quota.reset_daily_at).toLocaleString()}
              </p>
            </div>
          )
        })}
      </div>
    </div>
  )
}
