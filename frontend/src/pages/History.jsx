import { ResponsiveContainer, LineChart, Line, XAxis, YAxis, Tooltip, CartesianGrid, PieChart, Pie, Cell, BarChart, Bar } from 'recharts';
import { motion } from 'framer-motion';
import { TrendingUp, Activity, Calendar } from 'lucide-react';

const weeklyData = [
    { name: 'Mon', intensity: 0.4 },
    { name: 'Tue', intensity: 0.6 },
    { name: 'Wed', intensity: 0.2 },
    { name: 'Thu', intensity: 0.8 },
    { name: 'Fri', intensity: 0.9 },
    { name: 'Sat', intensity: 0.5 },
    { name: 'Sun', intensity: 0.7 },
];

const emotionData = [
    { name: 'Joy', value: 400, color: '#a855f7' },
    { name: 'Sadness', value: 300, color: '#f43f5e' },
    { name: 'Anxiety', value: 300, color: '#0ea5e9' },
    { name: 'Boredom', value: 200, color: '#64748b' },
];

export default function History() {
    return (
        <div className="min-h-screen pt-20 pb-24 px-4 max-w-7xl mx-auto">
            <div className="mb-12">
                <h1 className="text-4xl font-black title-gradient mb-2">Emotional Trends</h1>
                <p className="text-gray-400">visualize your journey over time.</p>
            </div>

            <div className="grid md:grid-cols-3 gap-6 mb-8">
                <StatCard icon={TrendingUp} label="Current Streak" value="5 Days" />
                <StatCard icon={Activity} label="Avg Intensity" value="65%" />
                <StatCard icon={Calendar} label="Total Logs" value="42" />
            </div>

            <div className="grid md:grid-cols-2 gap-8">
                <motion.div
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.2 }}
                    className="glass-card p-6 h-96"
                >
                    <h2 className="text-xl font-bold mb-6">Weekly Intensity</h2>
                    <ResponsiveContainer width="100%" height="80%">
                        <LineChart data={weeklyData}>
                            <CartesianGrid strokeDasharray="3 3" stroke="#ffffff10" vertical={false} />
                            <XAxis dataKey="name" stroke="#64748b" tick={{ fontSize: 12 }} tickLine={false} axisLine={false} />
                            <YAxis stroke="#64748b" tick={{ fontSize: 12 }} tickLine={false} axisLine={false} />
                            <Tooltip
                                contentStyle={{ backgroundColor: '#0f172a', border: '1px solid #ffffff20', borderRadius: '8px' }}
                                itemStyle={{ color: '#fff' }}
                            />
                            <Line
                                type="monotone"
                                dataKey="intensity"
                                stroke="#8b5cf6"
                                strokeWidth={4}
                                dot={{ r: 4, fill: '#8b5cf6', strokeWidth: 0 }}
                                activeDot={{ r: 8, fill: '#fff' }}
                            />
                        </LineChart>
                    </ResponsiveContainer>
                </motion.div>

                <motion.div
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.4 }}
                    className="glass-card p-6 h-96"
                >
                    <h2 className="text-xl font-bold mb-6">Emotion Distribution</h2>
                    <ResponsiveContainer width="100%" height="80%">
                        <PieChart>
                            <Pie
                                data={emotionData}
                                cx="50%"
                                cy="50%"
                                innerRadius={60}
                                outerRadius={100}
                                paddingAngle={5}
                                dataKey="value"
                            >
                                {emotionData.map((entry, index) => (
                                    <Cell key={`cell-${index}`} fill={entry.color} stroke="none" />
                                ))}
                            </Pie>
                            <Tooltip contentStyle={{ backgroundColor: '#0f172a', border: '1px solid #ffffff20', borderRadius: '8px' }} />
                        </PieChart>
                    </ResponsiveContainer>
                    <div className="flex justify-center gap-4 text-xs text-gray-400 -mt-4">
                        {emotionData.map(e => (
                            <div key={e.name} className="flex items-center gap-1">
                                <div className="w-2 h-2 rounded-full" style={{ backgroundColor: e.color }} />
                                {e.name}
                            </div>
                        ))}
                    </div>
                </motion.div>
            </div>
        </div>
    )
}

const StatCard = ({ icon: Icon, label, value }) => (
    <motion.div
        whileHover={{ y: -5 }}
        className="glass-card p-6 flex items-center justify-between"
    >
        <div>
            <p className="text-gray-500 text-sm font-medium uppercase tracking-wider mb-1">{label}</p>
            <h3 className="text-3xl font-black text-white">{value}</h3>
        </div>
        <div className="w-12 h-12 rounded-2xl bg-white/5 flex items-center justify-center">
            <Icon className="text-primary-light" size={24} />
        </div>
    </motion.div>
)
