//
//  BindableViewController.swift
//  Neves
//
//  Created by aa on 2021/3/25.
//

var cellCount = 0
var modelCount = 0

class BindableViewController: TestBaseViewController {
    
    let testCount = 30
    
    let tableView = UITableView(frame: PortraitScreenBounds, style: .plain)
    
    var models = [JPModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cellCount = 0
        modelCount = 0
        
        for i in 0 ..< testCount {
            let model: JPModel
            if let m = JPWorkManager.findModel(for: i) {
                model = m
            } else {
                model = JPModel("打工人\(i + 1)号", i)
            }
            models.append(model)
        }
        
        jp.contentInsetAdjustmentNever(tableView)
        tableView.contentInset = .init(top: NavTopMargin, left: 0, bottom: DiffTabBarH, right: 0)
        tableView.registerCell(JPCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 100
        view.addSubview(tableView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard navigationController == nil else { return }
        JPWorkManager.filterWithoutWorking()
    }
    
}

extension BindableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(for: indexPath) as JPCell
        let model = models[indexPath.row]
        
//        if let bindView = model.bindView {
//            JPrint("model.bindView.ex: \(bindView.tag)")
//        }
//        if let bindModel = cell.bindModel {
//            JPrint("view.bindModel.ex: \(bindModel.index)")
//        }
        
//        JPrint("~~~")
        
//        cell ~~~ model
        model ~~~ cell
        
//        cell.tag = indexPath.row
//        if let bindView = model.bindView {
//            JPrint("model.bindView.ex: \(bindView.tag)")
//        }
//        if let bindModel = cell.bindModel {
//            JPrint("view.bindModel.ex: \(bindModel.index)")
//        }
//        JPrint("------------------------")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = models[indexPath.row]
        
//        let cell = tableView.cellForRow(at: indexPath) as! JPCell
//        JPrint("cell:", String(format: "%p", cell))
//        if let bindModel = cell.bindModel {
//            JPrint("cell.bindModel:", String(format: "%p", bindModel))
//        } else {
//            JPrint("cell.bindModel: 空的")
//        }
//
//        JPrint("model:", String(format: "%p", model))
//        if let bindView = model.bindView {
//            JPrint("model.bindView:", String(format: "%p", bindView))
//        } else {
//            JPrint("model.bindView: 空的")
//        }
//
//        JPrint("--------------------------------")
        
        JPWorkManager.addWorkQueue(model)
    }
}

class JPCell: UITableViewCell, CellReusable, VBindable {
    static var nib: UINib? { nil }
    
    let nameLabel = UILabel()
    let stateLabel = UILabel()
    let stopBtn = UIButton(type: .custom)
    
    var bindModel: JPModel? = nil {
        didSet {
            nameLabel.text = bindModel?.name
            updateState()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .systemGreen
        
        nameLabel.textColor = .systemBlue
        nameLabel.font = .systemFont(ofSize: 20.px)
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.equalToSuperview().offset(20.px)
        }
        
        stateLabel.textColor = .systemPink
        stateLabel.font = .systemFont(ofSize: 15.px)
        stateLabel.textAlignment = .right
        contentView.addSubview(stateLabel)
        stateLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.right.equalToSuperview().offset(-20.px)
        }
        
        stopBtn.setImage(UIImage(named: "rocket_tc_icon_close"), for: .normal)
        stopBtn.addTarget(self, action: #selector(strike), for: .touchUpInside)
        stopBtn.isHidden = true
        contentView.addSubview(stopBtn)
        stopBtn.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 15.px, height: 15.px))
            $0.centerY.equalToSuperview()
            $0.right.equalTo(stateLabel.snp.left).offset(-8.px)
        }
        
        cellCount += 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        cellCount -= 1
        JPrint("JPCell 卒，剩", cellCount)
    }
    
    func updateState() {
        let state = bindModel?.state ?? .idle
        switch state {
        case .idle:
            stateLabel.text = ""
        case .prepare:
            stateLabel.text = "准备工作..."
        case let .working(progress):
            stateLabel.text = "正在工作 \(String(format: "%.0f", progress * 100))%"
        case .done:
            stateLabel.text = "完成工作"
        }
        stopBtn.isHidden = state == .idle || state == .done
    }
    
    @objc func strike() {
        guard let model = bindModel else { return }
        JPWorkManager.stop(model)
    }
}

class JPModel: NSObject, MBindable {
    let name: String
    
    let identifier: Int
    weak var bindView: JPCell? = nil
    
    var state: JPWorkState = .idle {
        didSet {
            bindView?.updateState()
        }
    }
    
    init(_ name: String, _ identifier: Int) {
        self.name = name
        self.identifier = identifier
        
        modelCount += 1
    }
    
    deinit {
        modelCount -= 1
        JPrint("JPModel 卒，剩", modelCount)
    }
}

// MARK:- 工作状态
enum JPWorkState: Equatable {
    case idle // 空闲
    case prepare // 准备中
    case working(progress: CGFloat) // 工作中
    case done // 完成
}

// MARK:- 工作模拟队列

final class JPWorkManager {
    
    // MARK: 存储属性
    static let maxWorkingCount = 3
    private(set) static var workQueue: [JPModel] = []
    private static var loopTimer: Timer? = nil
    
    // MARK: 计算属性
    static var workingCount: Int {
        return workQueue.reduce(0) {
            switch $1.state {
            case .working: return $0 + 1
            default: return $0
            }
        }
    }
    
    // MARK: 模型是否在工作队列中
    static func isInQueue(_ model: JPModel) -> Bool {
        for kModel in workQueue where kModel == model {
            return true
        }
        return false
    }
    
    // MARK: 查找模型
    static func findModel(for identifier: Int) -> JPModel? {
        for model in workQueue where model.identifier == identifier {
            return model
        }
        return nil
    }
    
    // MARK: 加入工作
    static func addWorkQueue(_ model: JPModel) {
        guard model.state == .idle, !isInQueue(model) else {
            return
        }
        model.state = .prepare
        workQueue.append(model)
        startWork()
    }
    
    // MARK: 停止工作
    static func stop(_ model: JPModel) {
        model.state = .idle
        removeModel(model)
        startWork()
    }
    
    // MARK: 停止所有工作
    static func stopAll() {
        removeTimer()
        let queue = workQueue
        workQueue.removeAll()
        for model in queue {
            model.state = .idle
        }
    }
    
    // MARK: 过滤没有工作中的模型
    static func filterWithoutWorking() {
        removeTimer()
        workQueue = workQueue.filter {
            switch $0.state {
            case .working: return true
            default: return false
            }
        }
        beginTimer()
    }
}

private extension JPWorkManager {
    
    // MARK: 开始工作（最多同时3个一起工作）
    static func startWork() {
        var workingCount = self.workingCount
        
        for model in workQueue {
            guard workingCount < maxWorkingCount else {
                break
            }
            
            switch model.state {
            case .prepare:
                model.state = .working(progress: 0)
                workingCount += 1
            default: break
            }
        }
        
        if workingCount > 0 {
            beginTimer()
        } else {
            removeTimer()
        }
    }
    
    // MARK: 开始计时
    static func beginTimer() {
        guard loopTimer == nil,
              workQueue.count > 0 else { return }
        let timer = Timer(timeInterval: 1.0, repeats: true) { _ in
            workworkwork()
        }
        RunLoop.main.add(timer, forMode: .common)
        loopTimer = timer
    }
    
    // MARK: 停止计时
    static func removeTimer() {
        guard let timer = loopTimer else { return }
        timer.invalidate()
        loopTimer = nil
    }
    
    // MARK: 工作工作工作
    static func workworkwork() {
        guard workQueue.count > 0 else {
            removeTimer()
            return
        }
        
        for model in workQueue {
            switch model.state {
            case var .working(progress):
                progress += 0.01
                if progress >= 1 {
                    finish(model)
                    break
                }
                model.state = .working(progress: progress)
            default:
                break
            }
        }
    }
    
    // MARK: 完成工作
    static func finish(_ model: JPModel) {
        model.state = .done
        removeModel(model)
        startWork()
    }
    
    // MARK: 移除模型
    static func removeModel(_ model: JPModel) {
        guard let index = workQueue.firstIndex(of: model) else {
            return
        }
        workQueue.remove(at: index)
        if workQueue.count == 0 {
            removeTimer()
        }
    }
}

