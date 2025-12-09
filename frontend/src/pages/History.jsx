import { ResponsiveContainer, LineChart, Line, XAxis, YAxis, Tooltip, CartesianGrid } from 'recharts';

const data = [
    { name: 'Mon', intensity: 0.4 },
    { name: 'Tue', intensity: 0.6 },
    { name: 'Wed', intensity: 0.2 },
    { name: 'Thu', intensity: 0.8 },
    { name: 'Fri', intensity: 0.9 },
    { name: 'Sat', intensity: 0.5 },
    { name: 'Sun', intensity: 0.7 },
];

export default function History() {
    return (
        <div className="p-8 max-w-7xl mx-auto min-h-screen">
            <div className="mb-12">
                <h1 className="text-4xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-blue-400 to-cyan-500 mb-2">Mood Trends</h1>
                <p className="text-gray-300">Visualize your emotional journey.</p>
            </div>

            <div className="glass-card h-96 p-4">
                <h2 className="text-xl font-bold mb-4">Weekly Intensity</h2>
                <ResponsiveContainer width="100%" height="100%">
                    <LineChart data={data}>
                        <CartesianGrid strokeDasharray="3 3" stroke="#ffffff20" />
                        <XAxis dataKey="name" stroke="#ffffff60" />
                        <YAxis stroke="#ffffff60" />
                        <Tooltip contentStyle={{ backgroundColor: '#0f172a', border: '1px solid #ffffff20' }} />
                        <Line type="monotone" dataKey="intensity" stroke="#22d3ee" strokeWidth={3} dot={{ r: 6, fill: '#22d3ee' }} />
                    </LineChart>
                </ResponsiveContainer>
            </div>
        </div>
    )
}
