import { motion } from 'framer-motion';
import { Play, Heart, Share2, MoreHorizontal, Disc } from 'lucide-react';
import { useState, useEffect } from 'react';
import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api/v1';

export default function Music() {
    const [playlists, setPlaylists] = useState([]);
    const [currentPlaylist, setCurrentPlaylist] = useState(null);
    const [activeMood, setActiveMood] = useState('chill');
    const [loading, setLoading] = useState(false);

    const fetchMusic = async (mood, keepCurrent = false) => {
        setLoading(true);
        setActiveMood(mood);
        try {
            const res = await axios.get(`${API_URL}/music/?mood=${mood}`);
            setPlaylists(res.data.playlists || []);
            if (!keepCurrent && res.data.playlists?.length > 0) {
                setCurrentPlaylist(res.data.playlists[0]);
            }
        } catch (e) {
            console.error("Failed to fetch music", e);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        const params = new URLSearchParams(window.location.search);
        const uri = params.get('uri');
        const mood = params.get('mood');

        if (uri && uri.startsWith('spotify:')) {
            // Auto-load suggested
            setCurrentPlaylist({ uri });
            // Fetch grid items but keep our specific playlist active
            fetchMusic(mood || 'chill', true);
        } else {
            fetchMusic(mood || 'chill');
        }
    }, [window.location.search]);

    const getEmbedUrl = (uri) => {
        if (!uri) return '';
        const parts = uri.split(':');
        if (parts.length < 3) return '';
        const type = parts[1];
        const id = parts[2];
        return `https://open.spotify.com/embed/${type}/${id}?utm_source=generator&theme=0`;
    };

    return (
        <div className="min-h-screen pt-20 pb-24 px-4 max-w-7xl mx-auto font-sans">
            <div className="flex flex-col md:flex-row justify-between items-end mb-8 gap-6">
                <div>
                    <h1 className="text-5xl font-black text-transparent bg-clip-text bg-gradient-to-r from-purple-400 via-pink-400 to-indigo-400 drop-shadow-lg mb-4">
                        Sonic Heal
                    </h1>
                    <p className="text-gray-400 max-w-lg">AI-curated soundscapes to harmonize your current emotional state.</p>
                </div>
                <div className="flex gap-2">
                    {['chill', 'focus', 'energize', 'sad', 'happy', 'christian', 'top hits'].map((mood) => (
                        <button
                            key={mood}
                            onClick={() => fetchMusic(mood)}
                            className={`px-4 py-2 rounded-full border text-sm capitalize transition-all duration-300 ${activeMood === mood
                                ? 'bg-primary border-primary text-white shadow-lg shadow-primary/30'
                                : 'border-white/10 text-gray-400 hover:bg-white/5 hover:text-white'
                                }`}
                        >
                            {mood}
                        </button>
                    ))}
                </div>
            </div>

            {/* Hero Player (Embed) */}
            <div className="glass-card overflow-hidden mb-12 flex flex-col md:flex-row min-h-[300px] shadow-2xl rounded-3xl border border-white/5 bg-black/40">
                {currentPlaylist ? (
                    <div className="w-full h-full min-h-[352px]">
                        <iframe
                            style={{ borderRadius: "12px" }}
                            src={getEmbedUrl(currentPlaylist.uri)}
                            width="100%"
                            height="352"
                            frameBorder="0"
                            allowFullScreen=""
                            allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture"
                            loading="lazy"
                        ></iframe>
                    </div>
                ) : (
                    <div className="w-full flex items-center justify-center p-12 text-gray-500">
                        {loading ? 'Loading curated tracks...' : 'Select a mood to start'}
                    </div>
                )}
            </div>

            {/* Grid */}
            <h3 className="text-2xl font-bold mb-6 flex items-center gap-2 capitalize">
                <Disc className="animate-spin-slow" />
                {activeMood === 'Suggested' ? 'Current Recommendation' : `Recommended for ${activeMood}`}
            </h3>

            {loading ? (
                <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-6">
                    {[...Array(6)].map((_, i) => (
                        <div key={i} className="aspect-square bg-white/5 rounded-2xl animate-pulse" />
                    ))}
                </div>
            ) : (
                <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-5 gap-6">
                    {/* If suggested, we accept that the grid shows 'chill' fallback for now, 
                        or we could filter? For now, showing more options is good. */}
                    {playlists.map((item, i) => (
                        <motion.div
                            key={i}
                            whileHover={{ y: -8, scale: 1.02 }}
                            whileTap={{ scale: 0.98 }}
                            className={`group cursor-pointer bg-white/5 p-3 rounded-2xl hover:bg-white/10 transition-colors border border-white/5 hover:border-white/20 relative ${currentPlaylist?.uri === item.uri ? 'ring-2 ring-primary bg-white/10' : ''
                                }`}
                            onClick={() => setCurrentPlaylist(item)}
                        >
                            <div className="aspect-square rounded-xl mb-4 relative overflow-hidden shadow-lg bg-black">
                                <img
                                    src={item.image}
                                    alt={item.name}
                                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                                    onError={(e) => e.target.src = 'https://via.placeholder.com/300?text=Music'}
                                />
                                {currentPlaylist?.uri === item.uri && (
                                    <div className="absolute inset-0 bg-black/40 flex items-center justify-center">
                                        <div className="w-12 h-12 rounded-full bg-primary flex items-center justify-center shadow-xl animate-pulse">
                                            <div className="w-3 h-3 bg-white rounded-full animate-bounce mx-0.5" />
                                            <div className="w-3 h-3 bg-white rounded-full animate-bounce mx-0.5" style={{ animationDelay: '0.1s' }} />
                                            <div className="w-3 h-3 bg-white rounded-full animate-bounce mx-0.5" style={{ animationDelay: '0.2s' }} />
                                        </div>
                                    </div>
                                )}
                                <div className={`absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center ${currentPlaylist?.uri === item.uri ? 'hidden' : ''}`}>
                                    <div className="w-12 h-12 rounded-full bg-green-500 flex items-center justify-center shadow-xl translate-y-4 group-hover:translate-y-0 transition-transform">
                                        <Play size={20} fill="black" className="ml-1 text-black" />
                                    </div>
                                </div>
                            </div>
                            <h3 className="font-bold truncate text-white mb-1" title={item.name}>{item.name}</h3>
                            <p className="text-xs text-gray-400 line-clamp-2">{item.description}</p>
                            <div className="mt-2 text-[10px] text-gray-500 uppercase tracking-wider font-bold">
                                {item.tracks_count} Tracks
                            </div>
                        </motion.div>
                    ))}
                </div>
            )}
        </div>
    )
}
