import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import Landing from './pages/Landing';
import Login from './pages/Login';
import Register from './pages/Register';
import Dashboard from './pages/Dashboard';
import Games from './pages/Games';
import Music from './pages/Music';
import Journal from './pages/Journal';
import Lockbox from './pages/Lockbox';
import Chat from './pages/Chat';
import History from './pages/History';
import Voice from './pages/Voice';

import Layout from './components/Layout';

const ProtectedRoute = ({ children }) => {
  const { token, loading } = useAuth();
  // Don't redirect while loading auth state, ideally
  if (!token && !loading) return <Navigate to="/login" />;

  return (
    <Layout>
      {children}
    </Layout>
  );
};

function AppRoutes() {
  return (
    <Routes>
      <Route path="/" element={<Landing />} />
      <Route path="/login" element={<Login />} />
      <Route path="/register" element={<Register />} />
      <Route path="/dashboard" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
      <Route path="/games" element={<ProtectedRoute><Games /></ProtectedRoute>} />
      <Route path="/music" element={<ProtectedRoute><Music /></ProtectedRoute>} />
      <Route path="/journal" element={<ProtectedRoute><Journal /></ProtectedRoute>} />
      <Route path="/lockbox" element={<ProtectedRoute><Lockbox /></ProtectedRoute>} />
      <Route path="/chat" element={<ProtectedRoute><Chat /></ProtectedRoute>} />
      <Route path="/history" element={<ProtectedRoute><History /></ProtectedRoute>} />
      <Route path="/voice" element={<ProtectedRoute><Voice /></ProtectedRoute>} />
    </Routes>
  );
}

export default function App() {
  return (
    <Router>
      <AuthProvider>
        <div className="min-h-screen text-white font-sans">
          <AppRoutes />
        </div>
      </AuthProvider>
    </Router>
  );
}
