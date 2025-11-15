import { useEffect, useState } from 'react'
import { supabase, Account } from '../lib/supabase'

export function useAccounts() {
  const [accounts, setAccounts] = useState<Account[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    // Initial fetch
    async function fetchAccounts() {
      try {
        const { data, error: fetchError } = await supabase
          .from('accounts')
          .select('*')
          .order('created_at', { ascending: false })

        if (fetchError) throw fetchError

        setAccounts(data || [])
      } catch (err) {
        setError(err as Error)
      } finally {
        setLoading(false)
      }
    }

    fetchAccounts()

    // Subscribe to real-time updates
    const channel = supabase
      .channel('account_updates')
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'accounts',
        },
        (payload) => {
          if (payload.eventType === 'INSERT') {
            setAccounts((prev) => [payload.new as Account, ...prev])
          } else if (payload.eventType === 'UPDATE') {
            setAccounts((prev) =>
              prev.map((a) => (a.id === payload.new.id ? (payload.new as Account) : a))
            )
          } else if (payload.eventType === 'DELETE') {
            setAccounts((prev) => prev.filter((a) => a.id !== payload.old.id))
          }
        }
      )
      .subscribe()

    return () => {
      channel.unsubscribe()
    }
  }, [])

  const addAccount = async (provider: string, email: string) => {
    const { data: { user } } = await supabase.auth.getUser()

    if (!user) throw new Error('Not authenticated')

    const { data, error } = await supabase
      .from('accounts')
      .insert({
        user_id: user.id,
        provider,
        email,
        status: 'pending',
      })
      .select()
      .single()

    if (error) throw error

    return data
  }

  const deleteAccount = async (accountId: string) => {
    const { error } = await supabase.from('accounts').delete().eq('id', accountId)

    if (error) throw error
  }

  return { accounts, loading, error, addAccount, deleteAccount }
}
