
import { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import {
    LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
    PieChart, Pie, Cell
} from 'recharts';
import { TrendingUp, Activity, Calendar } from 'lucide-react';
import axios from 'axios';
import { useAuth } from '../context/AuthContext';

export default function History() {
    const { user } = useAuth();
    const [history, setHistory] = useState([]);
    const [stats, setStats] = useState({ total: 0, topMood: 'N/A', currentStreak: 0 });

    useEffect(() => {
        if (!user) return;
        const fetchHistory = async () => {
            try {
                const res = await axios.get(`http://localhost:8000/api/mood/history?user_id=${user.id}`);
                setHistory(res.data);

                // Calculate Stats
                const total = res.data.length;
                const moods = res.data.map(i => i.mood);
                const topMood = moods.sort((a, b) =>
                    moods.filter(v => v === a).length - moods.filter(v => v === b).length
                ).pop() || "N/A";

                setStats({ total, topMood, currentStreak: Math.min(total, 5) }); // Mock streak logic for now

            } catch (e) {
                console.error(e);
            }
        };
        fetchHistory();
    }, [user]);

    // Data Transformation for Charts
    const lineData = history.slice().reverse().map((h, i) => ({
        name: i + 1, // Simple index, ideally date
        intensity: h.intensity * 100,
        mood: h.mood
    }));

    const pieData = Object.entries(
        history.reduce((acc, curr) => {
            acc[curr.mood] = (acc[curr.mood] || 0) + 1;
            return acc;
        }, {})
    ).map(([name, value]) => ({ name, value }));

    const COLORS = ['#6366f1', '#d946ef', '#22d3ee', '#10b981', '#f59e0b'];

    return (
        <div className="pt-10 px-4 pb-20 max-w-6xl mx-auto space-y-8">
            <h1 className="text-4xl font-black title-gradient">Mood Insights</h1>

            {/* Stats Cards */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <StatCard icon={Activity} label="Total Check-ins" value={stats.total} color="text-primary-light" />
                <StatCard icon={TrendingUp} label="Top Mood" value={stats.topMood} color="text-secondary" />
                <StatCard icon={Calendar} label="Current Streak" value={`${stats.currentStreak} Days`} color="text-accent" />
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
                {/* Line Chart */}
                <div className="glass-card p-6 md:p-8">
                    <h3 className="text-xl font-bold mb-6">Intensity Trend</h3>
                    <div className="h-[300px] w-full">
                        <ResponsiveContainer width="100%" height="100%">
                            <LineChart data={lineData}>
                                <CartesianGrid strokeDasharray="3 3" stroke="#ffffff10" />
                                <XAxis dataKey="name" hide />
                                <YAxis stroke="#94a3b8" />
                                <Tooltip
                                    contentStyle={{ backgroundColor: '#0f172a', border: '1px solid #334155', borderRadius: '12px' }}
                                    itemStyle={{ color: '#e2e8f0' }}
                                    labelStyle={{ color: '#94a3b8' }}
                                />
                                <Line type="monotone" dataKey="intensity" stroke="#818cf8" strokeWidth={3} dot={{ fill: '#6366f1' }} />
                            </LineChart>
                        </ResponsiveContainer>
                    </div>
                </div>

                {/* Pie Chart */}
                <div className="glass-card p-6 md:p-8">
                    <h3 className="text-xl font-bold mb-6">Mood Distribution</h3>
                    <div className="h-[300px] w-full">
                        <ResponsiveContainer width="100%" height="100%">
                            <PieChart>
                                <Pie
                                    data={pieData}
                                    cx="50%"
                                    cy="50%"
                                    innerRadius={60}
                                    outerRadius={100}
                                    paddingAngle={5}
                                    dataKey="value"
                                >
                                    {pieData.map((entry, index) => (
                                        <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                                    ))}
                                </Pie>
                                <Tooltip
                                    contentStyle={{ backgroundColor: '#0f172a', border: '1px solid #334155', borderRadius: '12px' }}
                                    itemStyle={{ color: '#e2e8f0' }}
                                />
                            </PieChart>
                        </ResponsiveContainer>
                    </div>
                </div>
            </div>

            <div className="glass-card p-6 md:p-8">
                <h3 className="text-xl font-bold mb-6">Recent Entries</h3>
                {history.length === 0 ? <p className="text-gray-500">No data found.</p> : (
                    <div className="space-y-4">
                        {history.slice(0, 5).map((item, i) => (
                            <div key={i} className="flex justify-between items-center p-4 bg-white/5 rounded-xl border border-white/5">
                                <div>
                                    <div className="font-bold capitalize text-lg text-white">{item.mood}</div>
                                    <div className="text-xs text-gray-500">{new Date(item.created_at).toLocaleString()}</div>
                                </div>
                                <div className="text-primary-light font-bold">{(item.intensity * 100).toFixed(0)}%</div>
                            </div>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
}

const StatCard = ({ icon: Icon, label, value, color }) => (
    <div className="glass-card p-6 flex items-center gap-6">
        <div className={`p-4 rounded-2xl bg-white/5 ${color}`}>
            <Icon size={32} />
        </div>
        <div>
            <div className="text-gray-400 text-sm uppercase tracking-wider font-bold">{label}</div>
            <div className="text-3xl font-black text-white">{value}</div>
        </div>
    </div>
);
