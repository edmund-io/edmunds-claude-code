import { useEffect, useState } from 'react'
import { supabase, Quota } from '../lib/supabase'

export function useQuotas() {
  const [quotas, setQuotas] = useState<Quota[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    // Initial fetch
    async function fetchQuotas() {
      try {
        const { data, error: fetchError } = await supabase
          .from('quotas')
          .select('*, accounts(provider, email, status)')
          .order('provider')

        if (fetchError) throw fetchError

        setQuotas(data || [])
      } catch (err) {
        setError(err as Error)
      } finally {
        setLoading(false)
      }
    }

    fetchQuotas()

    // Subscribe to real-time updates
    const channel = supabase
      .channel('quota_updates')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'quotas',
        },
        (payload) => {
          if (payload.eventType === 'INSERT') {
            setQuotas((prev) => [...prev, payload.new as Quota])
          } else if (payload.eventType === 'UPDATE') {
            setQuotas((prev) =>
              prev.map((q) => (q.id === payload.new.id ? (payload.new as Quota) : q))
            )
          } else if (payload.eventType === 'DELETE') {
            setQuotas((prev) => prev.filter((q) => q.id !== payload.old.id))
          }
        }
      )
      .subscribe()

    return () => {
      channel.unsubscribe()
    }
  }, [])

  return { quotas, loading, error }
}
