#include <mex.hpp>
#include <mexAdapter.hpp>
#include <MatlabDataArray.hpp>

#include <queue>


namespace AStarPairs
{
    
template<typename real>
struct Vec3
{
    real x;
    real y;
    real z;

    Vec3(real x, real y, real z) : x(x), y(y), z(z) { }
    Vec3(const real* v) : x(v[0]), y(v[1]), z(v[2]) { }
    Vec3(const AStarPairs::Vec3<real>& V) : x(V.x), y(V.y), z(V.z) { }

    real dist2(const AStarPairs::Vec3<real>& V) const
    {
        double xx = x - V.x;
        double yy = y - V.y;
        double zz = z - V.z;
        return xx * xx + yy * yy + zz * zz;
    }

    real dist(const AStarPairs::Vec3<real>& V) const { return std::sqrt(dist2(V)); }
};


template<typename real>
struct QueueEntry
{
    real Guess;
    real Dist;
    int Index;

    QueueEntry(real Guess, real Dist, int Index) : Guess(Guess), Dist(Dist), Index(Index) { }
};


template<typename real>
struct QueueGreater
{
    constexpr bool operator()(const AStarPairs::QueueEntry<real>& a, 
                              const AStarPairs::QueueEntry<real>& b)
    {
        if (a.Guess > b.Guess)
            return true;
        if (b.Guess > a.Guess)
            return false;
        if (a.Dist > b.Dist)
            return true;
        if (b.Dist > a.Dist)
            return false;
        if (a.Index > b.Index)
            return true;
        return false;
    }
};


template<typename real>
class Graph
{
private:
    std::vector<AStarPairs::Vec3<real>> m_Pos;
    std::vector<std::pair<int, real>> m_Edges;
    std::vector<int> m_Idxs;

public:
    Graph(const real* vdata, int nv, const int* edata, int ne)
    {
        m_Pos.reserve(nv);
        for (int i = 0; i < nv; ++i)
            m_Pos.emplace_back(vdata + 3 * i);
        
        m_Idxs.reserve(nv + 1);
        m_Edges.reserve(ne);
        m_Idxs.push_back(0);
        int prev = 0;
        for (int i = 0; i < ne; ++i)
        {
            int cur = edata[2 * i];
            while (cur != prev)
            {
                m_Idxs.push_back(i);
                prev++;
            }
            real d = m_Pos[edata[2 * i]].dist(m_Pos[edata[2 * i + 1]]);
            m_Edges.emplace_back(edata[2 * i + 1], d);
        }
        while (m_Idxs.size() < nv + 1)
            m_Idxs.push_back(ne);
    }
    ~Graph() { }

    real Distance(int i, int j) const
    {
        std::vector<real> dists;
        dists.resize(m_Pos.size(), std::numeric_limits<real>::infinity());

        std::vector<real> guess;
        guess.resize(m_Pos.size(), std::numeric_limits<real>::infinity());

        std::priority_queue<AStarPairs::QueueEntry<real>, 
                            std::vector<AStarPairs::QueueEntry<real>>, 
                            AStarPairs::QueueGreater<real>> pq;
        dists[i] = 0.0;
        guess[i] = m_Pos[i].dist(m_Pos[j]);
        pq.emplace(guess[i], dists[i], i);
        while (!pq.empty())
        {
            auto cur = pq.top();
            pq.pop();

            if (cur.Index == j)
                return cur.Dist;

            int nadj = m_Idxs[cur.Index + 1] - m_Idxs[cur.Index];
            for (int kk = 0; kk < nadj; ++kk)
            {
                int k = m_Edges[m_Idxs[cur.Index] + kk].first;
                real w = m_Edges[m_Idxs[cur.Index] + kk].second;
                w += dists[cur.Index];
                if (dists[k] <= w)
                    continue;
                dists[k] = w;
                guess[k] = w + m_Pos[k].dist(m_Pos[j]);
                pq.emplace(guess[k], w, k);
            }
        }

        // If disconnected components, return Euclidean distance
        return std::isinf(dists[j]) ? m_Pos[i].dist(m_Pos[j]) : dists[j];
    }
};

} // namespace AStarPairs





class MexFunction : public matlab::mex::Function
{
public:
    void check_args(matlab::mex::ArgumentList outputs,
                    matlab::mex::ArgumentList inputs)
    {
        std::shared_ptr<matlab::engine::MATLABEngine> matlabPtr = getEngine();

        matlab::data::ArrayFactory factory;

        // Three inputs are needed
        if (inputs.size() < 3)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Function needs three input matrices.") }
                             ));
        }

        // First input must be a three-rows single or double matrix
        if (inputs[0].getDimensions().size() != 2 && inputs[0].getDimensions()[0] != 3)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("First input must be a 3-by-N 2D matrix.") }
                             ));
        }

        if (inputs[0].getType() != matlab::data::ArrayType::DOUBLE && inputs[0].getType() != matlab::data::ArrayType::SINGLE)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("First input must be single or double.") }
                             ));
        }

        // Second input must be a 2-rows int matrix
        if (inputs[1].getDimensions().size() != 2 && inputs[1].getDimensions()[0] != 2)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Second input must be a 2-by-N 2D matrix.") }
                             ));
        }

        if (inputs[1].getType() != matlab::data::ArrayType::INT32 && inputs[1].getType() != matlab::data::ArrayType::INT32)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Second input must be int32.") }
                             ));
        }

        // Third input must be a 2-rows int matrix
        if (inputs[2].getDimensions().size() != 2 && inputs[2].getDimensions()[0] != 2)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Third input must be a 2-by-N 2D matrix.") }
                             ));
        }

        if (inputs[2].getType() != matlab::data::ArrayType::INT32 && inputs[2].getType() != matlab::data::ArrayType::INT32)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Third input must be int32.") }
                             ));
        }

        // Function has exactly one output
        if (outputs.size() != 1)
        {
            matlabPtr->feval(u"error",
                             0,
                             std::vector<matlab::data::Array>(
                                { factory.createScalar("Function has exactly one output.") }
                             ));
        }
    }

    template<typename T>
    const T* getDataPtr(matlab::data::Array arr) 
    {
        const matlab::data::TypedArray<T> arr_t = arr;
        matlab::data::TypedIterator<const T> it(arr_t.begin());
        return it.operator->();
    }

    void operator()(matlab::mex::ArgumentList outputs,
                    matlab::mex::ArgumentList inputs)
    {
        check_args(outputs, inputs);

        matlab::data::ArrayFactory factory;

        // Retrieve indices
        const int* edges = getDataPtr<int>(inputs[1]);
        const int* pairs = getDataPtr<int>(inputs[2]);

        // Single or double?
        if (inputs[0].getType() == matlab::data::ArrayType::DOUBLE)
        {
            const double* verts = getDataPtr<double>(inputs[0]);
            AStarPairs::Graph<double> G(verts, inputs[0].getDimensions()[1], edges, inputs[1].getDimensions()[1]);

            unsigned long long npairs = inputs[2].getDimensions()[1];
            outputs[0] = factory.createArray<double>(matlab::data::ArrayDimensions({ npairs, 1 }));
            for (unsigned long long i = 0; i < npairs; ++i)
                outputs[0][i] = G.Distance(pairs[2 * i], pairs[2 * i + 1]);
        }
        else
        {
            const float* verts = getDataPtr<float>(inputs[0]);
            AStarPairs::Graph<float> G(verts, inputs[0].getDimensions()[1], edges, inputs[1].getDimensions()[1]);

            unsigned long long npairs = inputs[2].getDimensions()[1];
            outputs[0] = factory.createArray<float>(matlab::data::ArrayDimensions({ npairs, 1 }));
            for (unsigned long long i = 0; i < npairs; ++i)
                outputs[0][i] = G.Distance(pairs[2 * i], pairs[2 * i + 1]);
        }
    }
};